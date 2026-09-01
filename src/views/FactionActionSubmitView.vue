<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { factionActionAPI, locationAPI, playerAPI } from '@/utils/api.js'
import { useGameDayScope } from '@/composables/useGameDayScope.js'
import { applyFactionPayload } from '@/utils/actionFormHydration.js'
import {
  FACTION_LABELS,
  FACTION_ACTION_DEFS,
  GM_FACTION_TABS,
  PERSONAL_DAY_ACTION_OPTIONS,
  EXTRA_DAY_ACTION_TYPES,
  INVESTIGATE_TYPES,
} from '@/data/factionActions.js'
import { SABOTAGE_FACILITY_OPTIONS, getSabotageOptionByFacilityId } from '@/data/sabotageTargets.js'

const playerId = parseInt(localStorage.getItem('playerId') || '0')
const userRole = (localStorage.getItem('userRole') || '').toLowerCase()
const isGmView = computed(() => userRole === 'dm')

const {
  currentGameDay,
  phaseLabel,
  viewGameDay: gameDay,
  dayOptions,
  daytimeEditable,
  viewOnlyDaytimeReason,
  loadGameState,
  syncFromContext,
} = useGameDayScope()

const isHydrating = ref(false)
const viewFaction = ref('')
const context = ref(null)
const locations = ref([])
const loading = ref(true)
const submitting = ref(false)
const submitMessage = ref(null)
const showActionHelpModal = ref(false)

const selectedType = ref('')
const actionResult = ref('')

const forms = reactive({
  assign_personnel: {
    targetId: '',
    targetKind: 'player',
    actionCount: 1,
    assignedActions: [
      { action: '', targetLocationId: '', targetPlayerId: '' },
      { action: '', targetLocationId: '', targetPlayerId: '' },
    ],
    note: '',
  },
  assign_guard: { actorId: '', targetLocationId: '' },
  extra_labor: { note: '' },
  secret_contact: { targetPlayerId: '', message: '', anonymous: false },
  sabotage: { targetLocationId: '', facilityId: '' },
  extra_investigate: { investigateType: 'investigate_player', targetId: '' },
  guard_ark: { guardId: '', useWeaponOrSkill: false },
  ark_construction: {
    mode: 'resource',
    woodKg: 0, metalKg: 0, sealantKg: 0,
    warehouseWoodKg: 0, warehouseMetalKg: 0, warehouseSealantKg: 0,
    engineCount: 0, generatorCount: 0, propellerCount: 0, buildSail: false,
    workType: 'wood',
    note: '',
  },
  curse: { weaponId: '', target1: '', target2: '' },
  extra_action: { actionType: '', targetLocationId: '', targetPlayerId: '', note: '' },
})

const playerFaction = computed(() => context.value?.faction || '')
const displayFaction = computed(() => (isGmView.value && viewFaction.value) ? viewFaction.value : playerFaction.value)
const actionDefs = computed(() => FACTION_ACTION_DEFS[displayFaction.value] || [])
const factionMeta = computed(() => FACTION_LABELS[displayFaction.value] || { label: '未知', color: '' })

const locationOptions = computed(() =>
  (locations.value || []).map(l => ({ value: l.id, label: `${l.name}（${l.area || ''}）` }))
)

const allPlayers = computed(() => context.value?.allPlayers || [])
const militiaPlayers = computed(() => context.value?.militiaPlayers || [])
const governedIds = computed(() => new Set(context.value?.governedLocationIds || []))
const unlimitedActions = computed(() => !!context.value?.unlimitedActions)
const hasSubmittedToday = computed(() => !!context.value?.hasSubmittedToday)

function npcUnavailableForAssign(npc) {
  const status = npc && npc.status != null ? String(npc.status) : ''
  return ['死亡', '失踪', '离开', '被捕'].some((marker) => status.includes(marker))
}

const npcOptions = computed(() => {
  const out = []
  for (const loc of locations.value || []) {
    for (const n of loc.npcs || []) {
      if (npcUnavailableForAssign(n)) continue
      const attitude = n.attitudeRuler
      const attitudeHint = (attitude === '喜好' || attitude === '厌恶' || attitude === '忽视')
        ? `｜${attitude}统治者`
        : ''
      out.push({
        value: `npc:${n.id}`,
        id: n.id,
        kind: 'npc',
        attitudeRuler: attitude || null,
        label: `${n.name}（${n.job}）@ ${loc.name}${attitudeHint}`,
      })
    }
  }
  return out
})

const personnelTargetsUsedToday = computed(
  () => new Set(context.value?.personnelTargetsUsedToday || [])
)
const guardActorsUsedToday = computed(
  () => new Set((context.value?.guardActorsUsedToday || []).map((id) => Number(id)))
)

const personnelTargets = computed(() => {
  const used = personnelTargetsUsedToday.value
  return [
    ...allPlayers.value
      .filter((p) => !used.has(`player:${p.id}`))
      .map((p) => ({ value: `player:${p.id}`, id: p.id, kind: 'player', label: p.name })),
    ...npcOptions.value.filter((n) => !used.has(n.value)),
  ]
})

const assignPersonnelNpcWarning = computed(() => {
  const raw = forms.assign_personnel.targetId
  return typeof raw === 'string' && raw.startsWith('npc:')
})

const guardActorOptions = computed(() =>
  allPlayers.value.filter((p) => !guardActorsUsedToday.value.has(p.id))
)

const assignedFreeActionOptions = computed(() => {
  const opts = [...PERSONAL_DAY_ACTION_OPTIONS]
  if (context.value?.submitterCanProduce) {
    opts.splice(3, 0, { value: 'produce', label: '生产' })
  }
  return opts
})

const investigatePlayerOptions = computed(() =>
  allPlayers.value
    .filter((p) => p.id !== playerId)
    .map((p) => ({ value: p.id, label: p.name }))
)

const extraActionOptions = computed(() => {
  const opts = [...EXTRA_DAY_ACTION_TYPES]
  if (context.value?.submitterCanProduce) {
    // produce already in EXTRA_DAY_ACTION_TYPES
  }
  return opts
})

const extraActionNeedsLocation = computed(() => {
  const t = forms.extra_action.actionType
  return t === 'go_location'
})

const extraActionNeedsPlayer = computed(() => {
  const t = forms.extra_action.actionType
  return t === 'investigate_player'
})

const factionInvestigateTargetOptions = computed(() => {
  const type = forms.extra_investigate.investigateType
  if (type === 'investigate_location') {
    return locationOptions.value
  }
  return allPlayers.value
    .filter(p => p.id !== playerId)
    .map(p => ({ value: p.id, label: p.name }))
})

const arkProgress = computed(() => {
  const ark = context.value?.arkStatus
  if (!ark) return '—'
  return ark.completionPercentage != null ? `${ark.completionPercentage}%` : '—'
})

const arkLimits = computed(() => context.value?.arkResourceLimits || {
  playerWoodKg: 0, playerMetalKg: 0, playerSealantKg: 0,
  warehouseWoodKg: 0, warehouseMetalKg: 0, warehouseSealantKg: 0,
  playerEngine: 0, playerPropeller: 0, playerGenerator: 0,
  warehouseEngine: 0, warehousePropeller: 0, warehouseGenerator: 0,
  dailyWoodLimitKg: 30000, dailyMetalLimitKg: 20000, dailySealantLimitKg: 20,
})

const arkLimitWarnings = computed(() => {
  const f = forms.ark_construction
  const limits = arkLimits.value
  const warnings = []
  if (f.mode !== 'resource') return warnings

  const totalWoodKg = (parseFloat(f.woodKg) || 0) + (parseFloat(f.warehouseWoodKg) || 0)
  const totalMetalKg = (parseFloat(f.metalKg) || 0) + (parseFloat(f.warehouseMetalKg) || 0)
  const totalSealantKg = (parseInt(f.sealantKg) || 0) + (parseInt(f.warehouseSealantKg) || 0)

  if ((parseFloat(f.woodKg) || 0) > limits.playerWoodKg) {
    warnings.push('木材个人投入超出库存上限(' + limits.playerWoodKg + 'kg)')
  }
  if ((parseFloat(f.warehouseWoodKg) || 0) > limits.warehouseWoodKg) {
    warnings.push('木材仓库投入超出库存上限(' + limits.warehouseWoodKg + 'kg)')
  }
  if ((parseFloat(f.metalKg) || 0) > limits.playerMetalKg) {
    warnings.push('金属个人投入超出库存上限(' + limits.playerMetalKg + 'kg)')
  }
  if ((parseFloat(f.warehouseMetalKg) || 0) > limits.warehouseMetalKg) {
    warnings.push('金属仓库投入超出库存上限(' + limits.warehouseMetalKg + 'kg)')
  }
  if ((parseInt(f.sealantKg) || 0) > limits.playerSealantKg) {
    warnings.push('密封材料(沥青)个人投入超出库存上限(' + limits.playerSealantKg + 'kg)')
  }
  if ((parseInt(f.warehouseSealantKg) || 0) > limits.warehouseSealantKg) {
    warnings.push('密封材料(沥青)仓库投入超出库存上限(' + limits.warehouseSealantKg + 'kg)')
  }
  if (totalWoodKg / 1000 > 30) {
    warnings.push('木材总投入' + (totalWoodKg / 1000).toFixed(2) + '吨超出单次上限30吨')
  }
  if (totalMetalKg / 1000 > 20) {
    warnings.push('金属总投入' + (totalMetalKg / 1000).toFixed(2) + '吨超出单次上限20吨')
  }
  if (totalSealantKg > 20) {
    warnings.push('密封材料(沥青)总投入' + totalSealantKg + 'kg超出单次上限20kg')
  }

  const reqEngine = parseInt(f.engineCount) || 0
  const reqPropeller = parseInt(f.propellerCount) || 0
  const reqGenerator = parseInt(f.generatorCount) || 0
  const totalEngine = limits.playerEngine + limits.warehouseEngine
  const totalPropeller = limits.playerPropeller + limits.warehousePropeller
  const totalGenerator = limits.playerGenerator + limits.warehouseGenerator
  if (reqEngine > totalEngine) {
    warnings.push('发动机数量不足(个人' + limits.playerEngine + '个+仓库' + limits.warehouseEngine + '个，需要' + reqEngine + '个)')
  }
  if (reqPropeller > totalPropeller) {
    warnings.push('螺旋桨数量不足(个人' + limits.playerPropeller + '个+仓库' + limits.warehousePropeller + '个，需要' + reqPropeller + '个)')
  }
  if (reqGenerator > totalGenerator) {
    warnings.push('发电机数量不足(个人' + limits.playerGenerator + '个+仓库' + limits.warehouseGenerator + '个，需要' + reqGenerator + '个)')
  }

  return warnings
})

function clampArkInput(field, maxVal) {
  const f = forms.ark_construction
  if (f[field] > maxVal) {
    f[field] = maxVal
  }
  if (f[field] < 0) {
    f[field] = 0
  }
}

function onArkPersonalWoodChange() {
  clampArkInput('woodKg', arkLimits.value.playerWoodKg)
}

function onArkPersonalMetalChange() {
  clampArkInput('metalKg', arkLimits.value.playerMetalKg)
}

function onArkWarehouseWoodChange() {
  clampArkInput('warehouseWoodKg', arkLimits.value.warehouseWoodKg)
}

function onArkWarehouseMetalChange() {
  clampArkInput('warehouseMetalKg', arkLimits.value.warehouseMetalKg)
}

function onArkPersonalSealantChange() {
  clampArkInput('sealantKg', arkLimits.value.playerSealantKg)
}

function onArkWarehouseSealantChange() {
  clampArkInput('warehouseSealantKg', arkLimits.value.warehouseSealantKg)
}

const sabotageFacilityOptions = computed(() =>
  SABOTAGE_FACILITY_OPTIONS.map((o) => ({
    value: o.facilityId,
    label: o.label,
    locationId: o.locationId,
    governed: governedIds.value.has(o.locationId),
  }))
)

const selectedDef = computed(() =>
  actionDefs.value.find(d => d.type === selectedType.value) || null
)

const actionTypeOptions = computed(() =>
  actionDefs.value.map(def => {
    const st = getActionStatus(def.type)
    return {
      value: def.type,
      label: def.title,
      disabled: st.btn === 'disabled',
      statusLabel: st.label,
    }
  })
)

const currentStatus = computed(() =>
  selectedType.value ? getActionStatus(selectedType.value) : null
)
const canSubmit = computed(
  () =>
    daytimeEditable.value &&
    selectedType.value &&
    currentStatus.value?.btn === 'enabled' &&
    !isGmView.value &&
    !submitting.value &&
    !(selectedType.value === 'ark_construction' && arkLimitWarnings.value.length > 0)
)

const formReadOnly = computed(() => !daytimeEditable.value || isGmView.value)

function isRulerActionUsedToday(type) {
  if (type === 'assign_personnel') return assignPersonnelUsedToday.value
  if (type === 'assign_guard') return assignGuardUsedToday.value

  return false
}

function getActionStatus(type) {
  if (!type) return { key: 'none', label: '', btn: 'disabled' }
  if (!unlimitedActions.value && hasSubmittedToday.value) {
    return { key: 'quota', label: '今日已提交', btn: 'disabled' }
  }
  if (type === 'extra_labor' && !context.value?.hasProduceToday) {
    return { key: 'blocked', label: '今日未生产', btn: 'disabled' }
  }
  if (type === 'sabotage') {
    const opt = getSabotageOptionByFacilityId(forms.sabotage.facilityId)
    if (opt && governedIds.value.has(opt.locationId)) {
      return { key: 'blocked', label: '地点被监管', btn: 'disabled' }
    }
  }
  if (type === 'curse') {
    const weapons = context.value?.highThreatWeapons || []
    if (!weapons.length) return { key: 'blocked', label: '无威胁≥4武器', btn: 'disabled' }
  }
  return { key: 'ready', label: '可执行', btn: 'enabled' }
}

function resetFormFields(type) {
  const defaults = {
    assign_personnel: {
      targetId: '',
      targetKind: 'player',
      actionCount: 1,
      assignedActions: [
        { action: '', targetLocationId: '', targetPlayerId: '' },
        { action: '', targetLocationId: '', targetPlayerId: '' },
      ],
      note: '',
    },
    assign_guard: { actorId: '', targetLocationId: '' },
    extra_labor: { note: '' },
    secret_contact: { targetPlayerId: '', message: '', anonymous: false },
    sabotage: { targetLocationId: '', facilityId: '' },
    extra_investigate: { investigateType: 'investigate_player', targetId: '' },
    guard_ark: { guardId: '', useWeaponOrSkill: false },
    ark_construction: {
      mode: 'resource',
      woodKg: 0, metalKg: 0, sealantKg: 0,
      warehouseWoodKg: 0, warehouseMetalKg: 0, warehouseSealantKg: 0,
      engineCount: 0, generatorCount: 0, propellerCount: 0, buildSail: false,
      workType: 'wood',
      note: '',
    },
    curse: { weaponId: '', target1: '', target2: '' },
    extra_action: { actionType: '', targetLocationId: '', targetPlayerId: '', note: '' },
  }
  if (type && defaults[type]) {
    Object.assign(forms[type], defaults[type])
  }
}

watch(selectedType, (type, prev) => {
  if (isHydrating.value) return
  if (prev) resetFormFields(prev)
  if (!isHydrating.value) actionResult.value = ''
})

function onSabotageFacilityChange(facilityId) {
  const opt = getSabotageOptionByFacilityId(facilityId)
  forms.sabotage.facilityId = opt ? String(opt.facilityId) : ''
  forms.sabotage.targetLocationId = opt ? String(opt.locationId) : ''
}

watch(() => forms.extra_investigate.investigateType, () => {
  forms.extra_investigate.targetId = ''
})



async function loadContext() {
  loading.value = true
  try {
    let pid = playerId
    if (isGmView.value && (!pid || isNaN(pid))) {
      const players = await playerAPI.getAll()
      const list = Array.isArray(players) ? players : []
      pid = list[0]?.id || 1
    }
    const ctx = await factionActionAPI.getContext(pid, gameDay.value)
    context.value = ctx
    syncFromContext(ctx)
    hydrateFactionFromHistory()
    if (!isGmView.value && ctx?.faction) {
      viewFaction.value = ctx.faction
    } else if (isGmView.value && !viewFaction.value) {
      viewFaction.value = GM_FACTION_TABS[0]
    }
    if (selectedType.value) {
      const st = getActionStatus(selectedType.value)
      if (st.btn === 'disabled') {
        selectedType.value = ''
        actionResult.value = ''
      }
    }
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

function hydrateFactionFromHistory() {
  const history = context.value?.history
  if (!history?.length) {
    if (!isHydrating.value) {
      selectedType.value = ''
      actionResult.value = ''
    }
    return
  }
  isHydrating.value = true
  try {
    const entry = history[0]
    const type = entry.actionType
    if (type) {
      resetFormFields(type)
      applyFactionPayload(type, entry.payload || {}, forms)
      selectedType.value = type
      actionResult.value = entry.result || ''
    }
  } finally {
    isHydrating.value = false
  }
}

async function loadLocations() {
  try {
    const res = await locationAPI.getAll()
    locations.value = Array.isArray(res) ? res : []
  } catch (e) {
    locations.value = []
  }
}

watch(gameDay, () => {
  if (!isHydrating.value) {
    selectedType.value = ''
    actionResult.value = ''
  }
  loadContext()
})

watch(viewFaction, () => {
  selectedType.value = ''
  actionResult.value = ''
})

function buildPayload(type) {
  const f = forms[type]
  switch (type) {
    case 'assign_personnel': {
      const raw = f.targetId
      const [kind, id] = raw.includes(':') ? raw.split(':') : ['player', raw]
      const count = Math.min(2, Math.max(1, f.actionCount || 1))
      const assignedActions = f.assignedActions.slice(0, count).map((item) => {
        const row = {
          action: item.action,
          targetLocationId: item.targetLocationId ? parseInt(item.targetLocationId) : null,
        }
        if (item.action === 'investigate_player' && item.targetPlayerId) {
          row.targetPlayerId = parseInt(item.targetPlayerId)
        }
        return row
      })
      return {
        targetId: parseInt(id),
        targetKind: kind,
        assignedActions,
        note: f.note || '',
      }
    }
    case 'assign_guard':
      return {
        actorId: parseInt(f.actorId),
        targetLocationId: parseInt(f.targetLocationId),
      }
    case 'extra_labor':
      return { note: f.note || '' }
    case 'secret_contact':
      return { targetPlayerId: parseInt(f.targetPlayerId), message: f.message, anonymous: f.anonymous }
    case 'sabotage':
      return { targetLocationId: parseInt(f.targetLocationId), facilityId: parseInt(f.facilityId) }
    case 'extra_investigate':
      return {
        investigateType: f.investigateType,
        targetId: parseInt(f.targetId),
      }
    case 'guard_ark':
      return { guardId: parseInt(f.guardId), useWeaponOrSkill: f.useWeaponOrSkill }
    case 'ark_construction': {
      const f2 = forms.ark_construction
      const p = { mode: f2.mode, note: f2.note || '' }
      if (f2.mode === 'resource') {
        p.woodKg = parseFloat(f2.woodKg) || 0
        p.metalKg = parseFloat(f2.metalKg) || 0
        p.sealantKg = parseInt(f2.sealantKg) || 0
        p.warehouseWoodKg = parseFloat(f2.warehouseWoodKg) || 0
        p.warehouseMetalKg = parseFloat(f2.warehouseMetalKg) || 0
        p.warehouseSealantKg = parseInt(f2.warehouseSealantKg) || 0
        p.engineCount = parseInt(f2.engineCount) || 0
        p.generatorCount = parseInt(f2.generatorCount) || 0
        p.propellerCount = parseInt(f2.propellerCount) || 0
        p.buildSail = f2.buildSail
      } else if (f2.mode === 'work') {
        p.workType = f2.workType
      }
      return p
    }
    case 'curse':
      return {
        weaponId: parseInt(f.weaponId),
        target1: parseInt(f.target1),
        target2: f.target2 ? parseInt(f.target2) : null,
      }
    case 'extra_action':
      return {
        actionType: f.actionType,
        targetLocationId: f.targetLocationId ? parseInt(f.targetLocationId) : null,
        targetPlayerId: f.targetPlayerId ? parseInt(f.targetPlayerId) : null,
        note: f.note || '',
      }
    default:
      return {}
  }
}

function validateClient(type) {
  const f = forms[type]
  switch (type) {
    case 'assign_personnel': {
      if (!f.targetId) return '请选择目标'
      const count = Math.min(2, Math.max(1, f.actionCount || 1))
      for (let i = 0; i < count; i++) {
        const item = f.assignedActions[i]
        if (!item?.action) return `请填写第 ${i + 1} 项指定自由行动`
        if (item.action === 'investigate_player' && !item.targetPlayerId) {
          return `请为第 ${i + 1} 项「调查玩家」选择调查目标`
        }
        if (item.action === 'go_location' && !item.targetLocationId) {
          return `请为第 ${i + 1} 项「前往地点」选择地点`
        }
      }
      break
    }
    case 'assign_guard':
      if (!f.actorId || !f.targetLocationId) return '请选择看守人员与地点'
      break
    case 'secret_contact':
      if (!f.targetPlayerId || !f.message?.trim()) return '请选择目标并填写秘密信息'
      break
    case 'sabotage':
      if (!f.facilityId) return '请选择目标设施'
      break
    case 'extra_investigate':
      if (!f.targetId) return '请选择调查目标'
      break
    case 'guard_ark':
      if (!f.guardId) return '请选择看守人员'
      break
    case 'ark_construction': {
      const f2 = forms.ark_construction
      if (f2.mode === 'resource') {
        const hasRes = (parseFloat(f2.woodKg) > 0 || parseFloat(f2.metalKg) > 0 || parseInt(f2.sealantKg) > 0
          || parseFloat(f2.warehouseWoodKg) > 0 || parseFloat(f2.warehouseMetalKg) > 0 || parseInt(f2.warehouseSealantKg) > 0)
        const hasComp = (parseInt(f2.engineCount) > 0 || parseInt(f2.generatorCount) > 0 || parseInt(f2.propellerCount) > 0 || f2.buildSail)
        if (!hasRes && !hasComp) return '请至少投入一种资源或组件'
      } else if (f2.mode === 'work') {
        if (!f2.workType) return '请选择工作量推进类型'
      } else {
        return '请选择投入模式'
      }
      break
    }
    case 'curse':
      if (!f.weaponId || !f.target1) return '请选择武器与目标'
      break
    case 'extra_action':
      if (!f.actionType) return '请选择行动类型'
      if (f.actionType === 'go_location' && !f.targetLocationId) return '请选择前往地点'
      if (f.actionType === 'investigate_player' && !f.targetPlayerId) return '请选择调查目标'
      break
    default:
      break
  }
  return null
}

async function submitAction() {
  if (!daytimeEditable.value) {
    alert(viewOnlyDaytimeReason.value || '当前不可提交')
    return
  }
  if (!selectedType.value) {
    alert('请选择阵营行动')
    return
  }
  const err = validateClient(selectedType.value)
  if (err) {
    alert(err)
    return
  }
  const st = getActionStatus(selectedType.value)
  if (st.btn === 'disabled') return

  submitting.value = true
  submitMessage.value = null
  try {
    const res = await factionActionAPI.submitAction({
      playerId,
      actionType: selectedType.value,
      gameDay: gameDay.value,
      payload: buildPayload(selectedType.value),
    })
    if (res?.success) {
      actionResult.value = res.data?.result || '已提交'
      submitMessage.value = { type: 'success', text: '阵营行动提交成功' }
      await loadContext()
    } else {
      actionResult.value = '提交失败：' + (res?.message || '未知错误')
      submitMessage.value = { type: 'error', text: res?.message || '提交失败' }
    }
  } catch (e) {
    submitMessage.value = { type: 'error', text: '提交失败，请重试' }
  } finally {
    submitting.value = false
    if (submitMessage.value) {
      setTimeout(() => { submitMessage.value = null }, 3000)
    }
  }
}

function needsLocationForAssigned(action) {
  return action === 'go_location'
}

function needsPlayerTargetForAssigned(action) {
  return action === 'investigate_player'
}

const selectClass = 'w-full appearance-none bg-white/5 border border-white/10 rounded-xl px-4 py-3 pr-10 text-gray-200 text-sm focus:outline-none focus:border-blue-500/50'
const textareaClass = 'w-full resize-none bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-gray-200 text-sm placeholder:text-gray-600 focus:outline-none focus:border-blue-500/50'

onMounted(async () => {
  await loadGameState()
  await loadLocations()
  await loadContext()
})
</script>

<template>
  <div>
      <div class="text-center mb-10">
        <h1 class="text-white text-2xl md:text-3xl font-semibold tracking-tight mb-2">阵营行动</h1>
        <p class="text-gray-500 text-sm">选择阵营行动并提交</p>
        <div class="mt-3 flex items-center justify-center gap-2">
          <label class="text-gray-400 text-sm">查看天数：</label>
          <select
            v-model.number="gameDay"
            class="bg-black/30 border border-white/10 rounded-lg px-3 py-1 text-sm text-gray-200 focus:outline-none"
          >
            <option v-for="d in dayOptions" :key="d" :value="d">第 {{ d }} 天</option>
          </select>
          <span class="text-gray-600 text-xs">
            游戏第 {{ currentGameDay }} 天 · {{ phaseLabel }}
            <template v-if="gameDay === currentGameDay">（当前）</template>
          </span>
        </div>
      </div>

      <div
        v-if="viewOnlyDaytimeReason && !isGmView"
        class="mb-6 max-w-3xl mx-auto rounded-2xl border border-slate-500/40 bg-slate-500/10 px-5 py-3 text-center text-slate-300 text-sm"
      >
        {{ viewOnlyDaytimeReason }}
      </div>

      <div v-if="isGmView" class="mb-6 flex flex-wrap justify-center gap-2">
        <button
          v-for="f in GM_FACTION_TABS"
          :key="f"
          type="button"
          class="px-4 py-2 rounded-xl text-sm font-medium border transition-colors"
          :class="viewFaction === f ? 'bg-blue-600/30 border-blue-500/50 text-blue-200' : 'bg-white/5 border-white/10 text-gray-400 hover:text-white'"
          @click="viewFaction = f"
        >
          {{ FACTION_LABELS[f]?.label || f }}
        </button>
      </div>

      <div v-if="loading" class="flex justify-center py-20">
        <div class="w-12 h-12 border-4 border-blue-500 border-t-transparent rounded-full animate-spin" />
      </div>

      <div v-else-if="!isGmView && context && !context.success" class="text-center py-16">
        <p class="text-gray-400">{{ context.message || '暂无可用阵营行动。' }}</p>
      </div>

      <template v-else>

        <div class="max-w-3xl mx-auto mb-10">
          <div class="relative bg-gradient-to-br from-[#1a2332] to-[#0f1419] border border-white/10 rounded-3xl p-6 overflow-hidden">
            <div class="absolute top-0 right-0 w-48 h-48 bg-blue-500/5 rounded-full blur-3xl" />
            <fieldset class="relative space-y-4 border-0 p-0 m-0 min-w-0" :disabled="formReadOnly">
              <div class="flex items-center gap-3">
                <span class="inline-flex items-center justify-center w-9 h-9 rounded-lg bg-white/10 border border-white/10 text-gray-300 text-sm font-medium">⚔</span>
                <h2 class="text-white text-lg tracking-tight">阵营行动提交</h2>
                <span
                  v-if="currentStatus"
                  class="ml-auto text-xs px-2 py-0.5 rounded-full"
                  :class="{
                    'bg-green-500/20 text-green-400': currentStatus.key === 'ready',
                    'bg-gray-500/20 text-gray-400': currentStatus.key === 'used',
                    'bg-amber-500/20 text-amber-400': currentStatus.key === 'quota',
                    'bg-red-500/20 text-red-400': currentStatus.key === 'blocked',
                  }"
                >
                  {{ currentStatus.label }}
                </span>
              </div>

              <div>
                <div class="flex items-center gap-2 mb-2 ml-0.5">
                  <label class="text-gray-500 text-xs">选择行动</label>
                  <button
                    type="button"
                    class="inline-flex h-5 w-5 items-center justify-center rounded-full border border-white/20 bg-white/5 text-gray-400 hover:text-white text-xs font-semibold"
                    @click="showActionHelpModal = true"
                  >?</button>
                </div>
                <select v-model="selectedType" :class="selectClass" :disabled="formReadOnly">
                  <option value="">请选择行动</option>
                  <option
                    v-for="opt in actionTypeOptions"
                    :key="opt.value"
                    :value="opt.value"
                    :disabled="opt.disabled"
                  >
                    {{ opt.label }}{{ opt.disabled ? `（${opt.statusLabel}）` : '' }}
                  </option>
                </select>
              </div>

              <div v-if="selectedDef" class="rounded-xl border border-white/10 bg-black/20 px-4 py-3">
                <p class="text-gray-300 text-sm">{{ selectedDef.description }}</p>
              </div>

              <!-- 安排人员 -->
              <template v-if="selectedType === 'assign_personnel'">
                <p v-if="!assignPersonnelNpcWarning" class="text-amber-300/90 text-xs">对方须提交与你安排一致的一项或两项白天自由行动。全体统治者共享「安排人员」目标名额（同一玩家/NPC 当日仅可被安排一次）。</p>
                <p v-else class="text-amber-300/90 text-xs">NPC不会提交行动。系统按其对统治者的态度与你好感自动判定是否配合：忽视且好感≥0默认配合，负好感则拒绝；喜好需好感&gt;-60；厌恶需好感≥60。前往地点可自动落地，其余待主持人裁定。全体统治者共享「安排人员」目标名额（同一NPC当日仅可被安排一次）。</p>
                <div>
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">目标玩家/NPC</label>
                  <select v-model="forms.assign_personnel.targetId" :class="selectClass">
                    <option value="">请选择</option>
                    <option v-for="t in personnelTargets" :key="t.value" :value="t.value">{{ t.label }}</option>
                  </select>
                  <p
                    v-if="assignPersonnelNpcWarning"
                    class="text-amber-300/90 text-xs mt-2 leading-relaxed"
                  >
                    NPC 是否配合由系统按其对统治者的态度与你好感自动判定（态度见选项标注）。拒绝时可通过提升好感或给予利益争取，主持人可复核。
                  </p>
                </div>
                <div>
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">安排几项行动</label>
                  <select v-model.number="forms.assign_personnel.actionCount" :class="selectClass">
                    <option :value="1">一项</option>
                    <option :value="2">两项</option>
                  </select>
                </div>
                <div
                  v-for="idx in forms.assign_personnel.actionCount"
                  :key="'ap-'+idx"
                  class="rounded-xl border border-white/10 bg-black/20 p-3 space-y-3"
                >
                  <p class="text-gray-400 text-xs">第 {{ idx }} 项自由行动</p>
                  <select v-model="forms.assign_personnel.assignedActions[idx - 1].action" :class="selectClass">
                    <option value="">请选择</option>
                    <option v-for="a in assignedFreeActionOptions" :key="a.value" :value="a.value">{{ a.label }}</option>
                  </select>
                  <div v-if="needsLocationForAssigned(forms.assign_personnel.assignedActions[idx - 1].action)">
                    <label class="block text-gray-500 text-xs mb-2">前往地点</label>
                    <select v-model="forms.assign_personnel.assignedActions[idx - 1].targetLocationId" :class="selectClass">
                      <option value="">请选择地点</option>
                      <option v-for="o in locationOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
                    </select>
                  </div>
                  <div v-if="needsPlayerTargetForAssigned(forms.assign_personnel.assignedActions[idx - 1].action)">
                    <label class="block text-gray-500 text-xs mb-2">调查目标</label>
                    <select v-model="forms.assign_personnel.assignedActions[idx - 1].targetPlayerId" :class="selectClass">
                      <option value="">请选择玩家</option>
                      <option v-for="p in investigatePlayerOptions" :key="p.value" :value="p.value">{{ p.label }}</option>
                    </select>
                  </div>
                </div>
                <div>
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">附加说明</label>
                  <textarea v-model="forms.assign_personnel.note" rows="2" :class="textareaClass" />
                </div>
              </template>

              <!-- 安排看守 -->
              <template v-else-if="selectedType === 'assign_guard'">
                <p class="text-amber-300/90 text-xs">消耗对方夜晚行动点驻守地点；基础防御 +3。全体统治者共享「安排看守」人员名额（同一人当日仅可被安排一次）。本行动每日限用一次。</p>
                <div>
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">看守人员</label>
                  <select v-model="forms.assign_guard.actorId" :class="selectClass">
                    <option value="">请选择</option>
                    <option v-for="p in guardActorOptions" :key="p.id" :value="p.id">{{ p.name }}</option>
                  </select>
                </div>
                <div>
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">看守地点</label>
                  <select v-model="forms.assign_guard.targetLocationId" :class="selectClass">
                    <option value="">请选择地点</option>
                    <option v-for="o in locationOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
                  </select>
                </div>
              </template>

              <!-- 额外劳动 -->
              <!-- 额外劳动 -->
              <template v-else-if="selectedType === 'extra_labor'">
                <p v-if="!context?.hasProduceToday" class="text-red-400 text-sm">须今日已提交生产类自由行动。</p>
                <p v-else class="text-cyan-300/90 text-sm">结算后今日生产产出 +50%。物资在主持人发布后才会发放到背包。</p>
                <div class="mt-2">
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">备注（可选）</label>
                  <textarea v-model="forms.extra_labor.note" rows="2" :class="textareaClass" />
                </div>
              </template>

              <!-- 暗中联络 -->
              <template v-else-if="selectedType === 'secret_contact'">
                <div>
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">目标玩家</label>
                  <select v-model="forms.secret_contact.targetPlayerId" :class="selectClass">
                    <option value="">请选择</option>
                    <option v-for="p in allPlayers.filter(x => x.id !== playerId)" :key="p.id" :value="p.id">{{ p.name }}</option>
                  </select>
                </div>
                <div>
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">秘密信息</label>
                  <textarea v-model="forms.secret_contact.message" rows="3" :class="textareaClass" placeholder="输入秘密信息..." />
                </div>
                <label class="flex items-center gap-2 text-gray-400 text-sm">
                  <input v-model="forms.secret_contact.anonymous" type="checkbox" class="rounded" />
                  匿名发送
                </label>
              </template>

              <!-- 额外行动（反叛者） -->
              <template v-else-if="selectedType === 'extra_action'">
                <p class="text-amber-300/90 text-xs mb-3">在夜晚时间执行白天回合的一个任意行动。此环节无法寻找NPC进行对话。</p>
                <div>
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">选择行动类型</label>
                  <select v-model="forms.extra_action.actionType" :class="selectClass" @change="forms.extra_action.targetLocationId = ''; forms.extra_action.targetPlayerId = ''">
                    <option value="">请选择</option>
                    <option v-for="a in extraActionOptions" :key="a.value" :value="a.value">{{ a.label }}</option>
                  </select>
                </div>
                <div v-if="extraActionNeedsLocation">
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">前往地点</label>
                  <select v-model="forms.extra_action.targetLocationId" :class="selectClass">
                    <option value="">请选择地点</option>
                    <option v-for="o in locationOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
                  </select>
                </div>
                <div v-if="extraActionNeedsPlayer">
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">调查目标</label>
                  <select v-model="forms.extra_action.targetPlayerId" :class="selectClass">
                    <option value="">请选择玩家</option>
                    <option v-for="p in investigatePlayerOptions" :key="p.value" :value="p.value">{{ p.label }}</option>
                  </select>
                </div>
                <div>
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">备注（可选）</label>
                  <textarea v-model="forms.extra_action.note" rows="2" :class="textareaClass" />
                </div>
              </template>

              <!-- 破坏 -->
              <template v-else-if="selectedType === 'sabotage'">
                <div>
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">目标设施</label>
                  <select
                    :value="forms.sabotage.facilityId"
                    :class="selectClass"
                    @change="onSabotageFacilityChange($event.target.value)"
                  >
                    <option value="">请选择设施</option>
                    <option
                      v-for="o in sabotageFacilityOptions"
                      :key="o.value"
                      :value="o.value"
                      :disabled="o.governed"
                    >
                      {{ o.label }}{{ o.governed ? '（被监管，不可选）' : '' }}
                    </option>
                  </select>
                </div>
              </template>

              <!-- 额外调查 -->
              <template v-else-if="selectedType === 'extra_investigate'">
                <p class="text-amber-300/90 text-xs mb-3">
                  与「个人行动提交」调查相同：选择类型与目标。结算后该次调查数量翻倍。
                </p>
                <div class="space-y-4">
                  <div>
                    <label class="block text-gray-500 text-xs mb-2 ml-0.5">调查类型</label>
                    <select v-model="forms.extra_investigate.investigateType" :class="selectClass">
                      <option v-for="t in INVESTIGATE_TYPES" :key="t.value" :value="t.value">{{ t.label }}</option>
                    </select>
                  </div>
                  <div>
                    <label class="block text-gray-500 text-xs mb-2 ml-0.5">调查目标</label>
                    <select v-model="forms.extra_investigate.targetId" :class="selectClass">
                      <option value="">请选择</option>
                      <option
                        v-for="o in factionInvestigateTargetOptions"
                        :key="'inv-'+o.value"
                        :value="o.value"
                      >
                        {{ o.label }}
                      </option>
                    </select>
                  </div>
                </div>
              </template>

              <!-- 看守方舟 -->
              <template v-else-if="selectedType === 'guard_ark'">
                <div>
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">看守人员</label>
                  <select v-model="forms.guard_ark.guardId" :class="selectClass">
                    <option value="">请选择</option>
                    <option v-for="p in allPlayers" :key="p.id" :value="p.id">{{ p.name }}</option>
                  </select>
                </div>
                <label class="flex items-center gap-2 text-gray-400 text-sm">
                  <input v-model="forms.guard_ark.useWeaponOrSkill" type="checkbox" class="rounded" />
                  使用武器/技能计入防御
                </label>
              </template>

              <!-- 方舟建设 -->
              <template v-else-if="selectedType === 'ark_construction'">
                <p class="text-cyan-300 text-sm mb-2">当前方舟进度：{{ arkProgress }}</p>
                <div class="flex gap-2 mb-3">
                  <button type="button" class="flex-1 py-2 rounded-lg text-sm font-medium border transition-colors"
                    :class="forms.ark_construction.mode === 'resource' ? 'bg-cyan-600/30 border-cyan-500/50 text-cyan-200' : 'bg-white/5 border-white/10 text-gray-400'"
                    @click="forms.ark_construction.mode = 'resource'">资源投入</button>
                  <button type="button" class="flex-1 py-2 rounded-lg text-sm font-medium border transition-colors"
                    :class="forms.ark_construction.mode === 'work' ? 'bg-cyan-600/30 border-cyan-500/50 text-cyan-200' : 'bg-white/5 border-white/10 text-gray-400'"
                    @click="forms.ark_construction.mode = 'work'">工作量推进</button>
                </div>

                <template v-if="forms.ark_construction.mode === 'resource'">
                  <p class="text-amber-300/90 text-xs mb-3">每日投入上限：木材30吨、金属制品20吨、密封材料(沥青)20kg。发动机/发电机/螺旋桨/船帆无上限。资源可同时来源于个人物资和方舟仓库。</p>
                  <div class="rounded-xl border border-white/10 bg-black/20 p-3 space-y-3">
                    <p class="text-gray-400 text-xs font-medium">个人物资投入（kg）</p>
                    <div class="grid grid-cols-3 gap-2">
                      <div>
                        <label class="block text-gray-500 text-xs mb-1">木材(kg) <span class="text-gray-600">上限{{ arkLimits.playerWoodKg }}</span></label>
                        <input v-model.number="forms.ark_construction.woodKg" type="number" min="0" :max="arkLimits.playerWoodKg" step="100" :class="selectClass" @change="onArkPersonalWoodChange" />
                      </div>
                      <div>
                        <label class="block text-gray-500 text-xs mb-1">金属(kg) <span class="text-gray-600">上限{{ arkLimits.playerMetalKg }}</span></label>
                        <input v-model.number="forms.ark_construction.metalKg" type="number" min="0" :max="arkLimits.playerMetalKg" step="100" :class="selectClass" @change="onArkPersonalMetalChange" />
                      </div>
                      <div>
                        <label class="block text-gray-500 text-xs mb-1">密封材料/沥青(kg) <span class="text-gray-600">上限{{ arkLimits.playerSealantKg }}</span></label>
                        <input v-model.number="forms.ark_construction.sealantKg" type="number" min="0" :max="arkLimits.playerSealantKg" step="1" :class="selectClass" @change="onArkPersonalSealantChange" />
                      </div>
                    </div>
                  </div>
                  <div class="rounded-xl border border-white/10 bg-black/20 p-3 space-y-3">
                    <p class="text-gray-400 text-xs font-medium">方舟仓库投入（kg）</p>
                    <div class="grid grid-cols-3 gap-2">
                      <div>
                        <label class="block text-gray-500 text-xs mb-1">木材(kg) <span class="text-gray-600">上限{{ arkLimits.warehouseWoodKg }}</span></label>
                        <input v-model.number="forms.ark_construction.warehouseWoodKg" type="number" min="0" :max="arkLimits.warehouseWoodKg" step="100" :class="selectClass" @change="onArkWarehouseWoodChange" />
                      </div>
                      <div>
                        <label class="block text-gray-500 text-xs mb-1">金属(kg) <span class="text-gray-600">上限{{ arkLimits.warehouseMetalKg }}</span></label>
                        <input v-model.number="forms.ark_construction.warehouseMetalKg" type="number" min="0" :max="arkLimits.warehouseMetalKg" step="100" :class="selectClass" @change="onArkWarehouseMetalChange" />
                      </div>
                      <div>
                        <label class="block text-gray-500 text-xs mb-1">密封材料/沥青(kg) <span class="text-gray-600">上限{{ arkLimits.warehouseSealantKg }}</span></label>
                        <input v-model.number="forms.ark_construction.warehouseSealantKg" type="number" min="0" :max="arkLimits.warehouseSealantKg" step="1" :class="selectClass" @change="onArkWarehouseSealantChange" />
                      </div>
                    </div>
                  </div>
                  <div class="rounded-xl border border-cyan-500/20 bg-cyan-500/5 px-3 py-2 text-xs text-gray-300 space-y-0.5">
                    <p>木材合计：{{ ((forms.ark_construction.woodKg || 0) + (forms.ark_construction.warehouseWoodKg || 0)).toFixed(0) }}kg = {{ (((forms.ark_construction.woodKg || 0) + (forms.ark_construction.warehouseWoodKg || 0)) / 1000).toFixed(2) }}吨 <span class="text-gray-500">/ 每日上限30吨</span></p>
                    <p>金属合计：{{ ((forms.ark_construction.metalKg || 0) + (forms.ark_construction.warehouseMetalKg || 0)).toFixed(0) }}kg = {{ (((forms.ark_construction.metalKg || 0) + (forms.ark_construction.warehouseMetalKg || 0)) / 1000).toFixed(2) }}吨 <span class="text-gray-500">/ 每日上限20吨</span></p>
                    <p>密封材料(沥青)合计：{{ (forms.ark_construction.sealantKg || 0) + (forms.ark_construction.warehouseSealantKg || 0) }}kg <span class="text-gray-500">/ 每日上限20kg</span></p>
                  </div>
                  <div class="rounded-xl border border-white/10 bg-black/20 p-3 space-y-3">
                    <p class="text-gray-400 text-xs font-medium">组件投入</p>
                    <div class="grid grid-cols-3 gap-2">
                      <div>
                        <label class="block text-gray-500 text-xs mb-1">发动机 <span class="text-gray-600">个人{{ arkLimits.playerEngine }}+仓库{{ arkLimits.warehouseEngine }}</span></label>
                        <input v-model.number="forms.ark_construction.engineCount" type="number" min="0" :max="arkLimits.playerEngine + arkLimits.warehouseEngine" :class="selectClass" />
                      </div>
                      <div>
                        <label class="block text-gray-500 text-xs mb-1">发电机 <span class="text-gray-600">个人{{ arkLimits.playerGenerator }}+仓库{{ arkLimits.warehouseGenerator }}</span></label>
                        <input v-model.number="forms.ark_construction.generatorCount" type="number" min="0" :max="arkLimits.playerGenerator + arkLimits.warehouseGenerator" :class="selectClass" />
                      </div>
                      <div>
                        <label class="block text-gray-500 text-xs mb-1">螺旋桨 <span class="text-gray-600">个人{{ arkLimits.playerPropeller }}+仓库{{ arkLimits.warehousePropeller }}</span></label>
                        <input v-model.number="forms.ark_construction.propellerCount" type="number" min="0" :max="arkLimits.playerPropeller + arkLimits.warehousePropeller" :class="selectClass" />
                      </div>
                    </div>
                    <label class="flex items-center gap-2 text-gray-400 text-sm">
                      <input v-model="forms.ark_construction.buildSail" type="checkbox" class="rounded" />
                      建造船帆
                    </label>
                  </div>
                </template>

                <template v-if="forms.ark_construction.mode === 'work'">
                  <p class="text-amber-300/90 text-xs mb-3">材料不足时，可消耗1个行动点通过工作量推进方舟进度（无需投入资源）。</p>
                  <div>
                    <label class="block text-gray-500 text-xs mb-2 ml-0.5">推进类型</label>
                    <select v-model="forms.ark_construction.workType" :class="selectClass">
                      <option value="wood">5吨木材当量</option>
                      <option value="metal">5吨金属当量</option>
                      <option value="sealant">5kg密封材料(沥青)当量</option>
                    </select>
                  </div>
                </template>

                <textarea v-model="forms.ark_construction.note" rows="2" :class="textareaClass" placeholder="备注（可选）" />
              </template>

              <!-- 诅咒 -->
              <template v-else-if="selectedType === 'curse'">
                <p class="text-gray-400 text-xs mb-2">效果：获知阵营、施加诅咒。武器威胁值须≥4。</p>
                <div>
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">消耗武器（威胁≥4）</label>
                  <select v-model="forms.curse.weaponId" :class="selectClass">
                    <option value="">请选择</option>
                    <option v-for="w in (context?.highThreatWeapons || [])" :key="w.weaponId" :value="w.weaponId">
                      {{ w.name }}（威胁{{ w.threatLevel }}）
                    </option>
                  </select>
                </div>
                <div>
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">诅咒目标1</label>
                  <select v-model="forms.curse.target1" :class="selectClass">
                    <option value="">请选择</option>
                    <option v-for="p in allPlayers.filter(x => x.id !== playerId)" :key="p.id" :value="p.id">{{ p.name }}</option>
                  </select>
                </div>
                <div>
                  <label class="block text-gray-500 text-xs mb-2 ml-0.5">诅咒目标2（可选）</label>
                  <select v-model="forms.curse.target2" :class="selectClass">
                    <option value="">不选</option>
                    <option v-for="p in allPlayers.filter(x => x.id !== playerId)" :key="'c2-'+p.id" :value="p.id">{{ p.name }}</option>
                  </select>
                </div>
              </template>

              <div>
                <label class="block text-gray-500 text-xs mb-2 ml-0.5">行动结果</label>
                <div class="min-h-[5.5rem] rounded-xl border border-white/10 bg-black/25 px-4 py-3 text-sm text-gray-400 whitespace-pre-wrap">
                  {{ actionResult || '结果将在此显示' }}
                </div>
              </div>
            </fieldset>
          </div>
        </div>

        <div v-if="submitMessage" class="flex justify-center mb-4">
          <div
            :class="['px-5 py-2.5 rounded-xl text-sm font-medium', submitMessage.type === 'success' ? 'bg-green-500/20 border border-green-500/30 text-green-400' : 'bg-red-500/20 border border-red-500/30 text-red-400']"
          >
            {{ submitMessage.text }}
          </div>
        </div>

        <div v-if="arkLimitWarnings.length" class="flex justify-center mb-4">
          <div class="max-w-3xl w-full bg-red-500/15 border border-red-500/30 rounded-xl px-5 py-3">
            <p class="text-red-400 text-sm font-medium mb-1">投入超限，无法提交</p>
            <ul class="text-red-300 text-xs space-y-1">
              <li v-for="(msg, idx) in arkLimitWarnings" :key="idx">{{ msg }}</li>
            </ul>
          </div>
        </div>

        <div class="flex justify-center pb-4">
          <button
            type="button"
            :disabled="!canSubmit"
            class="min-w-[200px] bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 disabled:from-gray-600 disabled:to-gray-600 text-white px-8 py-3 rounded-xl text-sm font-medium shadow-lg shadow-blue-500/30 transition-all"
            @click="submitAction"
          >
            {{ submitting ? '提交中...' : isGmView ? '主持人预览' : '提交行动' }}
          </button>
        </div>

        <div v-if="!isGmView && context?.history?.length" class="mt-8 max-w-3xl mx-auto">
          <h3 class="text-white text-lg font-medium mb-4">已提交的阵营行动</h3>
          <div class="space-y-3">
            <div
              v-for="item in context.history"
              :key="item.id"
              class="bg-gradient-to-br from-[#1a2332] to-[#0f1419] border border-white/10 rounded-xl p-4"
            >
              <div class="flex items-center justify-between mb-2">
                <span class="text-white text-sm font-medium">{{ item.actionTypeLabel }}</span>
                <span
                  class="text-xs px-2 py-0.5 rounded-full"
                  :class="item.resultPending || item.status === 'pending' ? 'bg-amber-500/20 text-amber-400' : 'bg-green-500/20 text-green-400'"
                >
                  {{ item.resultPending ? '待发布' : (item.status === 'pending' ? '待反馈' : '已反馈') }}
                </span>
              </div>
              <div v-if="item.result" class="text-gray-400 text-xs whitespace-pre-wrap bg-black/20 rounded-lg p-3 mt-2">{{ item.result }}</div>
            </div>
          </div>
        </div>
      </template>

      <Teleport to="body">
        <div v-if="showActionHelpModal" class="fixed inset-0 bg-black/75 flex items-center justify-center z-50 p-4" @click.self="showActionHelpModal = false">
          <div class="bg-[#161b22] border border-[#2a3444] rounded-[18px] max-w-lg w-full max-h-[85vh] overflow-hidden flex flex-col shadow-[0_24px_48px_-12px_rgba(0,0,0,0.55)]">
            <div class="flex items-start justify-between px-6 pt-6 pb-4 border-b border-[#252d3a] shrink-0">
              <div>
                <h2 class="text-white text-lg font-semibold tracking-tight">阵营行动说明</h2>
                <p class="text-[#a0aab7] text-xs mt-1.5">以下为各阵营行动规则</p>
              </div>
              <button type="button" class="text-[#a0aab7] hover:text-white p-1" @click="showActionHelpModal = false">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
              </button>
            </div>
            <div class="overflow-y-auto px-6 py-5 space-y-3">
              <div v-for="(entry, idx) in actionDefs" :key="entry.type" class="rounded-[10px] border border-[#253041] bg-[#1c2533] px-4 py-3.5">
                <p class="text-[#00d1ff] text-sm font-medium mb-2">{{ idx + 1 }}. {{ entry.title }}</p>
                <p class="text-[#a0aab7] text-sm leading-relaxed">{{ entry.description }}</p>
              </div>
            </div>
            <div class="px-6 py-5 border-t border-[#252d3a] shrink-0 flex justify-center">
              <button type="button" class="min-w-[140px] px-10 py-2.5 rounded-full bg-[#303e55] hover:bg-[#3a4d68] text-white text-sm" @click="showActionHelpModal = false">知道了</button>
            </div>
          </div>
        </div>
      </Teleport>
  </div>
</template>
