<script setup>
import { ref, reactive, computed, onMounted, watch, defineAsyncComponent } from 'vue'
import { useRouter } from 'vue-router'
import ArkProgressView from './ArkProgressView.vue'
import ShelterProgressView from './ShelterProgressView.vue'
import DmTradesOverview from './DmTradesOverview.vue'
import RebelMilestoneView from './RebelMilestoneView.vue'
import CatastrophePanel from '../components/CatastrophePanel.vue'
import WarehouseView from './WarehouseView.vue'
import ActionFeedbackView from './ActionFeedbackView.vue'
import FactionActionFeedbackView from './FactionActionFeedbackView.vue'
import NightActionSettlementView from './NightActionSettlementView.vue'
import QuickInteractionFeedbackView from './QuickInteractionFeedbackView.vue'
import DmPlayerInventoryView from './DmPlayerInventoryView.vue'
import DmPlayerNotebookView from './DmPlayerNotebookView.vue'
import DmCombatAssistView from './DmCombatAssistView.vue'
import GameSettingsView from './GameSettingsView.vue'
import DmItemCodexView from './DmItemCodexView.vue'
import RuleBookView from './RuleBookView.vue'
import DmSystemLogView from './DmSystemLogView.vue'
import EndgameSettlementView from './EndgameSettlementView.vue'
import DmExplorationSettlementView from './DmExplorationSettlementView.vue'
const DmNpcManagementView = defineAsyncComponent(() => import('./DmNpcManagementView.vue'))
const GameResetView = defineAsyncComponent(() => import('./GameResetView.vue'))
import MinesweeperGame from './MinesweeperGame.vue'
import DmPlayerModalInventory from '../components/DmPlayerModalInventory.vue'
import SnowEffect from '../components/SnowEffect.vue'
import { dmPlayerAPI, jobAPI, skillAPI, gameStateAPI, playerMarkerAPI } from '../utils/api.js'
import {
  PLAYER_NAME_MAX_LENGTH,
  USERNAME_MAX_LENGTH,
  PASSWORD_MAX_LENGTH
} from '../data/gameData.js'
import { useSidebar } from '../composables/useSidebar.js'

const { collapsed, mobileOpen, isMobile, toggle: toggleSidebar, closeMobile, sidebarVisible } = useSidebar()

const FACTIONS = ['统治者', '反叛者', '冒险者', '天灾使者', '平民', '外来者', '原住民']
/** 创建玩家时可选阵营 */
const CREATE_FACTIONS = ['统治者', '反叛者', '冒险者', '天灾使者', '平民', '外来者', '原住民']

const router = useRouter()
const username = localStorage.getItem('username') || ''
const activeTab = ref('players')
const inventoryInitialPlayerId = ref(null)

const DM_NAV = [
  { type: 'item', key: 'players', icon: '👥', label: '玩家管理' },
  { type: 'item', key: 'settings', icon: '⚙️', label: '游戏设置' },
  { type: 'item', key: 'codex', icon: '📚', label: '图鉴' },
  {
    type: 'folder',
    id: 'settlement',
    icon: '📅',
    label: '每日行动结算',
    children: [
      { key: 'actionFeedback', icon: '📋', label: '行动反馈' },
      { key: 'factionActionFeedback', icon: '🏴', label: '阵营行动反馈' },
      { key: 'nightActionSettlement', icon: '🌙', label: '夜晚行动结算' },
      { key: 'explorationSettlement', icon: '🗺️', label: '探索岛屿结算' },
      { key: 'quickInteractionFeedback', icon: '💬', label: '快速交互反馈' },
    ],
  },
  { type: 'item', key: 'combatAssist', icon: '⚔️', label: '战斗辅助' },
  { type: 'item', key: 'inventories', icon: '🎒', label: '玩家背包' },
  { type: 'item', key: 'playerNotebook', icon: '📓', label: '玩家笔记本' },
  { type: 'item', key: 'warehouse', icon: '📦', label: '仓库管理' },
  { type: 'item', key: 'trades', icon: '🤝', label: '交易一览' },
  {
    type: 'folder',
    id: 'factionPage',
    icon: '🏰',
    label: '阵营页面',
    children: [
      { key: 'shelter', icon: '🏠', label: '统治者避难所' },
      { key: 'ark', icon: '🚢', label: '方舟建造进度' },
      { key: 'milestones', icon: '🏁', label: '里程碑管理' },
      { key: 'catastrophe', icon: '⛈️', label: '天灾降临' },
    ],
  },
  { type: 'item', key: 'endgame', icon: '🏁', label: '终局结算' },
  { type: 'item', key: 'logs', icon: '📜', label: '系统日志' },
  { type: 'item', key: 'npc', icon: '👥', label: 'NPC 管理' },
  { type: 'item', key: 'reset', icon: '🔄', label: '游戏重置' },
  { type: 'item', key: 'game', icon: '🎮', label: '小游戏' },
  { type: 'item', key: 'ruleBook', icon: '📖', label: '规则书' },
]

const folderOpen = reactive({ settlement: false, factionPage: false })

function isFolderActive(folder) {
  return folder.children.some((child) => child.key === activeTab.value)
}

function toggleFolder(id) {
  if (!isMobile.value && collapsed.value) {
    collapsed.value = false
    folderOpen[id] = true
    return
  }
  folderOpen[id] = !folderOpen[id]
}

function selectDmTab(key) {
  activeTab.value = key
  if (isMobile.value) closeMobile()
}

const playerList = ref([])
const jobs = ref([])
const hiddenJobs = ref([])
const skills = ref([])
const playersLoading = ref(false)
const playersError = ref('')
const savingPlayer = ref(false)
const showPasswordIds = ref(new Set())
const createStartingItems = ref([])
const createInventoryRef = ref(null)
const gameState = ref({ currentDay: 1 })

const playerMarkersByPlayerId = ref({})
const markerAddForm = reactive({ name: '', note: '', visibleToPlayer: false })
const markerSaving = ref(false)

const filterForm = reactive({
  name: '',
  job: '',
  faction: ''
})

const snowIntensity = computed(() => {
  const day = gameState.value?.currentDay || 1
  if (day <= 1) return 'light'
  if (day <= 2) return 'medium'
  return 'heavy'
})

const showEditModal = ref(false)
const showCreateModal = ref(false)
const editingPlayer = ref(null)
const createForm = reactive({
  name: '',
  faction: '平民',
  jobId: '',
  skillId: '',
  loginUsername: '',
  loginPassword: 'test123',
  isWeak: false,
  isOverworked: false,
  isInjured: 0,
  isBound: false,
  dmNotes: '',
  hiddenJobId: ''
})

const jobNameById = computed(() => {
  const map = new Map()
  for (const job of jobs.value) {
    map.set(job.id, job.name)
  }
  return map
})

const jobFilterOptions = computed(() => {
  const names = new Set()
  for (const p of playerList.value) {
    if (p.jobName) names.add(p.jobName)
  }
  return [...names].sort((a, b) => a.localeCompare(b, 'zh-CN'))
})

function normalizePlayer(raw) {
  const faction =
    typeof raw.faction === 'string'
      ? raw.faction
      : raw.faction?.name ?? raw.faction ?? '平民'
  const jobId = raw.jobId ?? raw.job_id ?? null
  const skillId = raw.skillId ?? raw.skill_id ?? null
  return {
    id: raw.id,
    name: raw.name ?? '',
    jobId,
    jobName: raw.jobName ?? (jobId ? jobNameById.value.get(jobId) ?? '—' : '—'),
    skillId,
    skillName: raw.skillName ?? '—',
    faction,
    loginUsername: raw.loginUsername ?? '',
    loginPassword: raw.loginPassword ?? '',
    isWeak: Boolean(raw.isWeak ?? raw.is_weak),
    isOverworked: Boolean(raw.isOverworked ?? raw.is_overworked),
    isInjured: raw.isInjured ?? raw.is_injured ?? 0,
    isSeverelyInjured: Boolean(raw.isSeverelyInjured ?? raw.is_severely_injured),
    isDead: Boolean(raw.isDead ?? raw.is_dead),
    dailyConsumptionMet: Boolean(raw.dailyConsumptionMet),
    dmNotes: raw.dmNotes ?? raw.dm_notes ?? '',
    hiddenJobId: raw.hiddenJobId ?? raw.hidden_job_id ?? null,
    hiddenJobName: raw.hiddenJobName ?? raw.hidden_job_name ?? '',
    tradeBanned: Boolean(raw.tradeBanned ?? raw.trade_banned),
    tradeBanExempt: Boolean(raw.tradeBanExempt ?? raw.trade_ban_exempt),
    isBound: Boolean(raw.isBound ?? raw.is_bound),
    tradeBanReasons: Array.isArray(raw.tradeBanReasons) ? raw.tradeBanReasons : [],
    tradeBanActive: Boolean(raw.tradeBanActive)
  }
}

/** 无阵营/平民特性全员可选；阵营专属特性仅当玩家阵营完全匹配时可选（含外来者、原住民） */
const skillsForFaction = (faction) => {
  return skills.value.filter((s) => {
    const f = s.faction
    if (!f || f === '平民') return true
    return Boolean(faction) && f === faction
  })
}

const editJobSearch = ref('')
const editSkillSearch = ref('')
const createJobSearch = ref('')
const createSkillSearch = ref('')

function normalizePickerQuery(query) {
  return String(query || '').trim().toLowerCase()
}

function optionMatchesSearch(item, query, extraKeys = []) {
  const q = normalizePickerQuery(query)
  if (!q) return true
  if (String(item?.name || '').toLowerCase().includes(q)) return true
  return extraKeys.some((key) => String(item?.[key] || '').toLowerCase().includes(q))
}

function filterPickerOptions(list, query, selectedId, extraKeys = []) {
  const q = normalizePickerQuery(query)
  if (!q) return list
  return list.filter((item) => {
    if (selectedId !== '' && selectedId != null && item.id == selectedId) return true
    return optionMatchesSearch(item, query, extraKeys)
  })
}

function pickerVisibleSize(query, optionCount) {
  if (!normalizePickerQuery(query)) return 1
  return Math.min(8, Math.max(2, optionCount + 1))
}

const filteredEditJobs = computed(() =>
  filterPickerOptions(jobs.value, editJobSearch.value, editingPlayer.value?.jobId)
)
const filteredEditSkills = computed(() =>
  filterPickerOptions(
    skillsForFaction(editingPlayer.value?.faction),
    editSkillSearch.value,
    editingPlayer.value?.skillId,
    ['function']
  )
)
const filteredCreateJobs = computed(() =>
  filterPickerOptions(jobs.value, createJobSearch.value, createForm.jobId)
)
const filteredCreateSkills = computed(() =>
  filterPickerOptions(
    skillsForFaction(createForm.faction),
    createSkillSearch.value,
    createForm.skillId,
    ['function']
  )
)

function togglePasswordVisible(id) {
  const next = new Set(showPasswordIds.value)
  if (next.has(id)) next.delete(id)
  else next.add(id)
  showPasswordIds.value = next
}

const filteredPlayers = computed(() => {
  let rows = playerList.value
  const nameQ = filterForm.name.trim().toLowerCase()
  if (nameQ) {
    rows = rows.filter((p) => p.name.toLowerCase().includes(nameQ))
  }
  if (filterForm.job) {
    rows = rows.filter((p) => p.jobName === filterForm.job)
  }
  if (filterForm.faction) {
    rows = rows.filter((p) => p.faction === filterForm.faction)
  }
  return rows
})

const getFactionColor = (faction) => {
  const colors = {
    统治者: 'text-amber-400 bg-amber-500/20',
    反叛者: 'text-red-400 bg-red-500/20',
    冒险者: 'text-emerald-400 bg-emerald-500/20',
    天灾使者: 'text-purple-400 bg-purple-500/20',
    平民: 'text-gray-400 bg-gray-500/20',
    外来者: 'text-teal-400 bg-teal-500/20',
    原住民: 'text-lime-400 bg-lime-500/20'
  }
  return colors[faction] || colors['平民']
}

function effectiveInjuryLevel(player) {
  let level = Number(player?.isInjured) || 0
  if (player?.isSeverelyInjured) level = Math.max(level, 2)
  if (player?.isDead) level = Math.max(level, 3)
  return level
}

function injuryFieldsFromLevel(level) {
  const n = Number(level) || 0
  return {
    isInjured: n,
    isSeverelyInjured: n >= 2,
    isDead: n >= 3
  }
}

const getStatusBadges = (player) => {
  const badges = []
  if (player.isWeak) badges.push({ text: '虚弱', color: 'text-amber-400 bg-amber-500/20' })
  if (player.isOverworked) badges.push({ text: '过劳', color: 'text-blue-400 bg-blue-500/20' })
  const injury = effectiveInjuryLevel(player)
  if (injury === 3) badges.push({ text: '死亡', color: 'text-gray-400 bg-gray-600/30' })
  else if (injury === 2) badges.push({ text: '重伤', color: 'text-red-300 bg-red-600/30' })
  else if (injury === 1) badges.push({ text: '受伤', color: 'text-red-400 bg-red-500/20' })
  if (player.isBound) badges.push({ text: '束缚', color: 'text-orange-300 bg-orange-600/25' })
  if (badges.length === 0) badges.push({ text: '健康', color: 'text-emerald-400 bg-emerald-500/20' })
  return badges
}

function autoTradeBanReasons(player) {
  return (player.tradeBanReasons || []).filter((r) => r && r !== '手动禁止')
}

function tradeBanHint(player) {
  const auto = autoTradeBanReasons(player)
  const explain = '禁止交易为手动禁止；允许交易豁免自动禁止（今日劳工/重伤/束缚）'
  if (auto.length) return `自动禁止：${auto.join('；')}。${explain}`
  return explain
}

async function toggleTradeBanned(player, event) {
  const next = Boolean(event?.target?.checked)
  const prev = Boolean(player.tradeBanned)
  player.tradeBanned = next
  savingPlayer.value = true
  try {
    const result = await dmPlayerAPI.update(player.id, { tradeBanned: next })
    if (result?.success) {
      await loadPlayers()
    } else {
      player.tradeBanned = prev
      if (event?.target) event.target.checked = prev
      alert(result?.message || '更新禁止交易失败')
    }
  } catch (e) {
    player.tradeBanned = prev
    if (event?.target) event.target.checked = prev
    alert('更新禁止交易失败: ' + (e.message || '未知错误'))
  } finally {
    savingPlayer.value = false
  }
}

async function toggleTradeBanExempt(player, event) {
  const next = Boolean(event?.target?.checked)
  const prev = Boolean(player.tradeBanExempt)
  player.tradeBanExempt = next
  savingPlayer.value = true
  try {
    const result = await dmPlayerAPI.update(player.id, { tradeBanExempt: next })
    if (result?.success) {
      await loadPlayers()
    } else {
      player.tradeBanExempt = prev
      if (event?.target) event.target.checked = prev
      alert(result?.message || '更新交易豁免失败')
    }
  } catch (e) {
    player.tradeBanExempt = prev
    if (event?.target) event.target.checked = prev
    alert('更新交易豁免失败: ' + (e.message || '未知错误'))
  } finally {
    savingPlayer.value = false
  }
}

function getPlayerMarkers(playerId) {
  return playerMarkersByPlayerId.value[playerId] || []
}

function applyPlayerMarkersList(markers) {
  const map = {}
  for (const marker of markers || []) {
    const pid = marker.playerId
    if (pid == null) continue
    if (!map[pid]) map[pid] = []
    map[pid].push(marker)
  }
  playerMarkersByPlayerId.value = map
}

async function loadPlayerMarkers() {
  try {
    const userRole = localStorage.getItem('userRole') || 'dm'
    const result = await playerMarkerAPI.list(userRole)
    if (result?.success) {
      applyPlayerMarkersList(result.markers)
    }
  } catch (e) {
    console.error('加载玩家标记失败:', e)
  }
}

function resetMarkerAddForm() {
  markerAddForm.name = ''
  markerAddForm.note = ''
  markerAddForm.visibleToPlayer = false
}

async function addPlayerMarker() {
  if (!editingPlayer.value?.id || markerSaving.value) return
  const name = markerAddForm.name.trim()
  if (!name) return
  markerSaving.value = true
  try {
    const userRole = localStorage.getItem('userRole') || 'dm'
    const result = await playerMarkerAPI.add(
      editingPlayer.value.id,
      name,
      markerAddForm.visibleToPlayer,
      markerAddForm.note.trim() || undefined,
      userRole
    )
    if (result?.success) {
      applyPlayerMarkersList(result.markers)
      resetMarkerAddForm()
    } else {
      alert(result?.message || '添加标记失败')
    }
  } catch (e) {
    alert('添加标记失败: ' + (e.message || '未知错误'))
  } finally {
    markerSaving.value = false
  }
}

async function removePlayerMarker(markerId) {
  if (markerSaving.value) return
  markerSaving.value = true
  try {
    const userRole = localStorage.getItem('userRole') || 'dm'
    const result = await playerMarkerAPI.remove(markerId, userRole)
    if (result?.success) {
      applyPlayerMarkersList(result.markers)
    } else {
      alert(result?.message || '移除标记失败')
    }
  } catch (e) {
    alert('移除标记失败: ' + (e.message || '未知错误'))
  } finally {
    markerSaving.value = false
  }
}

async function loadJobs() {
  const list = await jobAPI.getAll()
  jobs.value = Array.isArray(list) ? list : []
  try {
    const all = await jobAPI.getAllJobsForDm()
    const allList = Array.isArray(all) ? all : []
    hiddenJobs.value = allList.filter((j) => j.hidden === true || j.hidden === 1)
  } catch {
    hiddenJobs.value = []
  }
}

async function loadSkills() {
  const list = await skillAPI.getAll()
  skills.value = Array.isArray(list) ? list : []
}

async function loadPlayers() {
  playersLoading.value = true
  playersError.value = ''
  try {
    const [result, stateResult] = await Promise.all([
      dmPlayerAPI.list(),
      gameStateAPI.get().catch(() => null)
    ])
    
    if (stateResult) {
      gameState.value = { currentDay: stateResult.currentDay || 1 }
    }
    
    if (!result?.success) {
      playerList.value = []
      playersError.value = result?.message || '无法加载玩家列表（请确认后端已启动）'
      return
    }
    const list = result.players || []
    playerList.value = list.map((p) => normalizePlayer(p))
    await loadPlayerMarkers()
  } catch (e) {
    playerList.value = []
    playersError.value = '加载玩家失败: ' + (e.message || '未知错误')
  } finally {
    playersLoading.value = false
  }
}

async function refreshPlayers() {
  await Promise.all([loadJobs(), loadSkills()])
  await loadPlayers()
}

const handleLogout = () => {
  localStorage.removeItem('userRole')
  localStorage.removeItem('username')
  localStorage.removeItem('playerId')
  router.push('/')
}

const openPlayerInventory = (playerId) => {
  inventoryInitialPlayerId.value = playerId
  activeTab.value = 'inventories'
}

const resetFilter = () => {
  filterForm.name = ''
  filterForm.job = ''
  filterForm.faction = ''
}

function openEditModal(player) {
  editingPlayer.value = {
    id: player.id,
    name: player.name,
    faction: player.faction,
    jobId: player.jobId ?? '',
    skillId: player.skillId ?? '',
    loginUsername: player.loginUsername ?? '',
    loginPassword: player.loginPassword ?? '',
    isWeak: player.isWeak,
    isOverworked: player.isOverworked,
    isInjured: effectiveInjuryLevel(player),
    isBound: Boolean(player.isBound),
    dmNotes: player.dmNotes ?? '',
    hiddenJobId: player.hiddenJobId ?? ''
  }
  editJobSearch.value = ''
  editSkillSearch.value = ''
  resetMarkerAddForm()
  showEditModal.value = true
}

function closeEditModal() {
  showEditModal.value = false
  editingPlayer.value = null
}

function factionButtonClass(faction, selected) {
  if (!selected) {
    return 'bg-white/5 border-white/10 text-gray-400 hover:bg-white/10 hover:text-gray-300'
  }
  return `${getFactionColor(faction)} border-white/20 font-medium`
}

function validateCreateForm() {
  const name = createForm.name.trim()
  if (!name) return '请输入玩家姓名'
  if (name.length > PLAYER_NAME_MAX_LENGTH) {
    return `玩家姓名不能超过 ${PLAYER_NAME_MAX_LENGTH} 个字符`
  }
  if (!CREATE_FACTIONS.includes(createForm.faction)) return '请选择阵营'
  if (createForm.jobId === '' || createForm.jobId == null) return '请选择职业'
  if (createForm.skillId === '' || createForm.skillId == null) return '请选择特性'
  const username = createForm.loginUsername.trim()
  if (!username) return '请填写登录账号'
  if (username.length > USERNAME_MAX_LENGTH) {
    return `登录账号不能超过 ${USERNAME_MAX_LENGTH} 个字符`
  }
  if (/\s/.test(username)) return '登录账号不能包含空白字符'
  const password = createForm.loginPassword
  if (!password || !String(password).trim()) return '请填写登录密码'
  if (password.length > PASSWORD_MAX_LENGTH) {
    return `登录密码不能超过 ${PASSWORD_MAX_LENGTH} 个字符`
  }
  return null
}

function openCreateModal() {
  createForm.name = ''
  createForm.faction = '统治者'
  createForm.jobId = ''
  createForm.skillId = ''
  createForm.loginUsername = ''
  createForm.loginPassword = 'test123'
  createForm.isWeak = false
  createForm.isOverworked = false
  createForm.isInjured = 0
  createForm.isBound = false
  createForm.dmNotes = ''
  createForm.hiddenJobId = ''
  createStartingItems.value = []
  createJobSearch.value = ''
  createSkillSearch.value = ''
  showCreateModal.value = true
}

function closeCreateModal() {
  showCreateModal.value = false
}

async function saveEditPlayer() {
  if (!editingPlayer.value) return
  const name = editingPlayer.value.name?.trim()
  if (!name) {
    alert('请输入玩家姓名')
    return
  }
  savingPlayer.value = true
  try {
    const payload = {
      name,
      faction: editingPlayer.value.faction,
      isWeak: editingPlayer.value.isWeak,
      isOverworked: editingPlayer.value.isOverworked,
      ...injuryFieldsFromLevel(editingPlayer.value.isInjured),
      isBound: Boolean(editingPlayer.value.isBound),
      loginUsername: editingPlayer.value.loginUsername?.trim() || undefined,
      loginPassword: editingPlayer.value.loginPassword || undefined,
      dmNotes: editingPlayer.value.dmNotes ?? '',
      hiddenJobId:
        editingPlayer.value.hiddenJobId === '' || editingPlayer.value.hiddenJobId == null
          ? null
          : Number(editingPlayer.value.hiddenJobId)
    }
    if (editingPlayer.value.jobId !== '' && editingPlayer.value.jobId != null) {
      payload.jobId = Number(editingPlayer.value.jobId)
    } else {
      payload.jobId = null
    }
    payload.skillId =
      editingPlayer.value.skillId !== '' && editingPlayer.value.skillId != null
        ? Number(editingPlayer.value.skillId)
        : null
    const result = await dmPlayerAPI.update(editingPlayer.value.id, payload)
    if (result?.success) {
      closeEditModal()
      await loadPlayers()
    } else {
      alert(result?.message || '保存失败')
    }
  } catch (e) {
    alert('保存失败: ' + (e.message || '未知错误'))
  } finally {
    savingPlayer.value = false
  }
}

async function createPlayer() {
  const validationError = validateCreateForm()
  if (validationError) {
    alert(validationError)
    return
  }
  const name = createForm.name.trim()
  savingPlayer.value = true
  try {
    const payload = {
      name,
      faction: createForm.faction,
      jobId: Number(createForm.jobId),
      skillId: Number(createForm.skillId),
      isWeak: createForm.isWeak,
      isOverworked: createForm.isOverworked,
      ...injuryFieldsFromLevel(createForm.isInjured),
      isBound: Boolean(createForm.isBound),
      loginUsername: createForm.loginUsername.trim(),
      loginPassword: createForm.loginPassword,
      dmNotes: createForm.dmNotes ?? '',
      hiddenJobId:
        createForm.hiddenJobId === '' || createForm.hiddenJobId == null
          ? null
          : Number(createForm.hiddenJobId)
    }
    if (createStartingItems.value.length > 0) {
      payload.startingItems = createStartingItems.value.map((i) => ({
        itemType: i.itemType,
        itemId: i.itemId,
        quantity: i.quantity
      }))
    }
    const result = await dmPlayerAPI.create(payload)
    if (result?.success) {
      closeCreateModal()
      await loadPlayers()
      const u = result.username || ''
      const p = result.password || 'test123'
      alert(`玩家已创建。\n登录账号：${u}\n密码：${p}`)
    } else {
      alert(result?.message || '创建失败')
    }
  } catch (e) {
    alert('创建失败: ' + (e.message || '未知错误'))
  } finally {
    savingPlayer.value = false
  }
}

async function handleDelete(player) {
  if (!confirm(`确定删除玩家「${player.name}」？此操作不可撤销。`)) return
  savingPlayer.value = true
  try {
    const result = await dmPlayerAPI.delete(player.id)
    if (result?.success) {
      await loadPlayers()
    } else {
      alert(result?.message || '删除失败')
    }
  } catch (e) {
    alert('删除失败: ' + (e.message || '未知错误'))
  } finally {
    savingPlayer.value = false
  }
}

watch(activeTab, (tab) => {
  for (const item of DM_NAV) {
    if (item.type === 'folder' && item.children.some((child) => child.key === tab)) {
      folderOpen[item.id] = true
    }
  }
  if (tab === 'players' && playerList.value.length === 0 && !playersLoading.value) {
    refreshPlayers()
  }
})

onMounted(() => {
  refreshPlayers()
})
</script>

<template>
  <!-- h-screen + overflow-hidden：侧栏固定；仅右侧 main 纵向滚动 -->
  <div class="flex h-screen max-h-[100dvh] overflow-hidden bg-[#0a0e1a]">
    <!-- 移动端遮罩层 -->
    <div
      v-if="isMobile && mobileOpen"
      class="fixed inset-0 bg-black/60 z-30 transition-opacity"
      @click="closeMobile"
    ></div>

    <!-- 移动端汉堡菜单按钮 -->
    <button
      v-if="isMobile && !mobileOpen"
      type="button"
      class="fixed top-3 left-3 z-40 w-11 h-11 flex items-center justify-center rounded-xl bg-sky-600/90 border border-sky-400/80 text-white shadow-lg shadow-sky-500/30 active:scale-95 transition-transform"
      aria-label="打开导航菜单"
      @click="toggleSidebar"
    >
      <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" />
      </svg>
    </button>

    <!-- Sidebar -->
    <aside
      v-if="!isMobile || mobileOpen"
      class="flex h-full flex-col border-r border-slate-700/50 relative transition-all duration-250 ease-in-out"
      :class="[
        isMobile
          ? 'fixed left-0 top-0 z-40 w-72'
          : (collapsed ? 'w-16 shrink-0' : 'w-64 shrink-0')
      ]"
      style="background: linear-gradient(to right, rgba(5, 10, 20, 0.95) 0%, rgba(15, 25, 40, 0.92) 50%, rgba(25, 40, 60, 0.88) 100%);"
      :aria-expanded="isMobile ? mobileOpen : !collapsed"
      aria-label="侧边导航"
    >
      <SnowEffect :intensity="snowIntensity" />
      <!-- 桌面端收起/展开按钮 -->
      <button
        v-if="!isMobile"
        type="button"
        class="absolute right-2 top-2 z-50 w-9 h-9 flex items-center justify-center rounded-lg bg-sky-600/80 border-2 border-sky-400/80 text-white hover:bg-sky-500 hover:border-sky-300 transition-all duration-200 shadow-lg shadow-sky-500/30"
        :aria-label="collapsed ? '展开侧边栏' : '收起侧边栏'"
        @click="toggleSidebar"
      >
        <svg class="w-5 h-5 transition-transform duration-250" :class="collapsed ? 'rotate-180' : ''" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
        </svg>
      </button>

      <div class="shrink-0 border-b border-slate-700/50 p-4 relative z-10 flex items-center justify-between">
        <h2 v-if="isMobile || !collapsed" class="text-white tracking-tight text-lg">DM管理中心</h2>
        <div v-else class="flex justify-center w-full">
          <span class="text-white text-lg">🎲</span>
        </div>
        <!-- 移动端关闭按钮 -->
        <button
          v-if="isMobile"
          type="button"
          class="w-9 h-9 flex items-center justify-center rounded-lg text-gray-400 hover:text-white hover:bg-white/10 transition-colors"
          aria-label="关闭导航"
          @click="closeMobile"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <nav class="min-h-0 flex-1 overflow-y-auto py-2" :class="isMobile ? 'p-4' : (collapsed ? 'px-1' : 'p-4')">
        <template v-for="item in DM_NAV" :key="item.id || item.key">
          <button
            v-if="item.type === 'item'"
            type="button"
            class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[44px]"
            :class="[activeTab === item.key ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300', (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center']"
            :title="(!isMobile && collapsed) ? item.label : ''"
            @click="selectDmTab(item.key)"
          >
            <span v-if="!isMobile && collapsed">{{ item.icon }}</span><span v-else>{{ item.label }}</span>
          </button>
          <div v-else class="mb-1">
            <button
              type="button"
              class="w-full text-left rounded-xl transition-colors font-medium min-h-[44px] flex items-center"
              :class="[
                isFolderActive(item)
                  ? (folderOpen[item.id] && (isMobile || !collapsed) ? 'text-white' : 'bg-[#2d4263] text-white')
                  : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
                (isMobile || !collapsed) ? 'px-4 py-3 justify-between' : 'px-2 py-3 justify-center'
              ]"
              :title="(!isMobile && collapsed) ? item.label : ''"
              @click="toggleFolder(item.id)"
            >
              <span v-if="!isMobile && collapsed">{{ item.icon }}</span>
              <span v-else>{{ item.label }}</span>
              <svg
                v-if="isMobile || !collapsed"
                class="w-4 h-4 shrink-0 transition-transform duration-200"
                :class="folderOpen[item.id] ? 'rotate-90' : ''"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
              </svg>
            </button>
            <div v-if="folderOpen[item.id] && (isMobile || !collapsed)" class="ml-3 mt-1 border-l border-white/10 pl-2">
              <button
                v-for="child in item.children"
                :key="child.key"
                type="button"
                class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[40px] px-3 py-2 text-sm"
                :class="activeTab === child.key ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300'"
                @click="selectDmTab(child.key)"
              >
                {{ child.label }}
              </button>
            </div>
          </div>
        </template>
      </nav>

      <div class="shrink-0 border-t border-[#1f2937] p-3">
        <div class="flex items-center" :class="(!isMobile && collapsed) ? 'flex-col gap-2' : 'justify-between'">
          <span class="text-gray-400 text-sm truncate" :class="(!isMobile && collapsed) ? 'text-xs' : ''">{{ (!isMobile && collapsed) ? username.charAt(0) : username }}</span>
          <button
            type="button"
            class="text-gray-500 hover:text-white text-sm transition-colors min-h-[44px] min-w-[44px] flex items-center justify-center"
            @click="handleLogout"
          >
            {{ (!isMobile && collapsed) ? '⏻' : '退出' }}
          </button>
        </div>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="min-h-0 min-w-0 flex-1 overflow-y-auto relative" style="background-image: url('/交互页面背景.png'); background-size: cover; background-position: center; background-repeat: no-repeat;">
      <div class="absolute inset-0 bg-slate-950/10"></div>
      <div class="relative z-10 p-4 md:p-8 min-h-full">
      <!-- Players Tab -->
      <div v-if="activeTab === 'players'" class="max-w-7xl rounded-xl p-6" style="background: rgba(15, 20, 35, 0.9);">
        <div class="mb-6 flex items-center justify-between">
          <div>
            <h1 class="text-white mb-1 tracking-tight text-2xl">玩家管理</h1>
            <p class="text-gray-500 text-sm">Player Management</p>
          </div>
          <div class="flex gap-2">
            <button
              type="button"
              class="bg-white/5 hover:bg-white/10 text-gray-300 px-4 py-2 rounded-xl text-sm transition-all disabled:opacity-50"
              :disabled="playersLoading"
              @click="refreshPlayers"
            >
              刷新
            </button>
            <button
              type="button"
              class="bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white px-4 py-2 rounded-xl transition-all text-sm shadow-lg shadow-blue-500/30 disabled:opacity-50"
              :disabled="savingPlayer"
              @click="openCreateModal"
            >
              添加玩家
            </button>
          </div>
        </div>

        <p v-if="playersError" class="mb-4 text-red-400 text-sm">{{ playersError }}</p>

        <!-- Filter Section -->
        <div class="bg-gradient-to-br from-[#1a2332] to-[#0f1419] border border-white/10 rounded-2xl p-5 mb-6">
          <div class="flex flex-wrap gap-4 items-end">
            <div class="flex-1 min-w-[200px]">
              <label class="block text-gray-400 text-xs mb-2">姓名</label>
              <input
                v-model="filterForm.name"
                type="text"
                placeholder="请输入玩家姓名"
                class="w-full bg-black/30 border border-white/10 rounded-xl px-4 py-2.5 text-gray-200 text-sm placeholder-gray-500 focus:outline-none focus:border-blue-500/50"
              />
            </div>
            <div class="flex-1 min-w-[200px]">
              <label class="block text-gray-400 text-xs mb-2">职业</label>
              <select
                v-model="filterForm.job"
                class="w-full bg-black/30 border border-white/10 rounded-xl px-4 py-2.5 text-gray-200 text-sm focus:outline-none focus:border-blue-500/50"
              >
                <option value="">全部职业</option>
                <option v-for="jobName in jobFilterOptions" :key="jobName" :value="jobName">
                  {{ jobName }}
                </option>
              </select>
            </div>
            <div class="flex-1 min-w-[200px]">
              <label class="block text-gray-400 text-xs mb-2">阵营</label>
              <select
                v-model="filterForm.faction"
                class="w-full bg-black/30 border border-white/10 rounded-xl px-4 py-2.5 text-gray-200 text-sm focus:outline-none focus:border-blue-500/50"
              >
                <option value="">全部阵营</option>
                <option v-for="f in FACTIONS" :key="f" :value="f">{{ f }}</option>
              </select>
            </div>
            <div class="flex gap-2 items-center">
              <span class="text-gray-500 text-xs">共 {{ filteredPlayers.length }} / {{ playerList.length }} 人</span>
              <button
                type="button"
                class="bg-white/5 hover:bg-white/10 text-gray-400 px-4 py-2.5 rounded-xl text-sm transition-all"
                @click="resetFilter"
              >
                重置筛选
              </button>
            </div>
          </div>
        </div>

        <!-- Player Table -->
        <div class="bg-gradient-to-br from-[#1a2332] to-[#0f1419] border border-white/10 rounded-2xl overflow-hidden">
          <div v-if="playersLoading" class="py-16 flex justify-center">
            <div class="w-10 h-10 border-4 border-cyan-500 border-t-transparent rounded-full animate-spin" />
          </div>
          <div v-else-if="filteredPlayers.length === 0" class="py-16 text-center text-gray-500 text-sm">
            {{ playerList.length === 0 ? '暂无玩家数据' : '没有符合筛选条件的玩家' }}
          </div>
          <div v-else class="overflow-x-auto">
            <table class="w-full">
              <thead class="bg-white/5">
                <tr>
                  <th class="text-left text-gray-400 text-xs font-medium px-4 py-4">ID</th>
                  <th class="text-left text-gray-400 text-xs font-medium px-4 py-4">姓名</th>
                  <th class="text-left text-gray-400 text-xs font-medium px-4 py-4">登录账号</th>
                  <th class="text-left text-gray-400 text-xs font-medium px-4 py-4">密码</th>
                  <th class="text-left text-gray-400 text-xs font-medium px-4 py-4">职业</th>
                  <th class="text-left text-gray-400 text-xs font-medium px-4 py-4">隐藏身份</th>
                  <th class="text-left text-gray-400 text-xs font-medium px-4 py-4">特性</th>
                  <th class="text-left text-gray-400 text-xs font-medium px-4 py-4">阵营</th>
                  <th class="text-left text-gray-400 text-xs font-medium px-4 py-4">状态</th>
                  <th class="text-left text-gray-400 text-xs font-medium px-2 py-4 max-w-[80px]">备注</th>
                  <th class="text-left text-gray-400 text-xs font-medium px-4 py-4">当日需求</th>
                  <th class="text-left text-gray-400 text-xs font-medium px-4 py-4">禁止交易</th>
                  <th class="text-left text-gray-400 text-xs font-medium px-4 py-4">操作</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-white/5">
                <tr v-for="player in filteredPlayers" :key="player.id" class="hover:bg-white/5 transition-colors">
                  <td class="px-4 py-4 text-gray-300 text-sm">{{ player.id }}</td>
                  <td class="px-4 py-4 text-white text-sm font-medium">{{ player.name }}</td>
                  <td class="px-4 py-4 text-gray-300 text-sm font-mono">{{ player.loginUsername || '—' }}</td>
                  <td class="px-4 py-4 text-gray-300 text-sm">
                    <span v-if="showPasswordIds.has(player.id)" class="font-mono">{{ player.loginPassword || '—' }}</span>
                    <span v-else>••••••</span>
                    <button
                      type="button"
                      class="ml-2 text-cyan-500/80 text-xs hover:text-cyan-400"
                      @click="togglePasswordVisible(player.id)"
                    >
                      {{ showPasswordIds.has(player.id) ? '隐藏' : '显示' }}
                    </button>
                  </td>
                  <td class="px-4 py-4 text-gray-300 text-sm">{{ player.jobName }}</td>
                  <td class="px-4 py-4 text-gray-300 text-sm">{{ player.hiddenJobName || '—' }}</td>
                  <td class="px-4 py-4 text-gray-300 text-sm max-w-[120px] truncate" :title="player.skillName">{{ player.skillName }}</td>
                  <td class="px-4 py-4">
                    <span :class="['text-xs px-2 py-1 rounded-full', getFactionColor(player.faction)]">
                      {{ player.faction }}
                    </span>
                  </td>
                  <td class="px-6 py-4">
                    <div class="flex flex-wrap gap-1">
                      <span
                        v-for="badge in getStatusBadges(player)"
                        :key="badge.text"
                        :class="['text-xs px-2 py-1 rounded-full', badge.color]"
                      >
                        {{ badge.text }}
                      </span>
                      <span
                        v-for="marker in getPlayerMarkers(player.id)"
                        :key="marker.id"
                        :title="marker.note || marker.name"
                        class="inline-flex items-center gap-0.5 text-xs px-2 py-1 rounded-full text-purple-300 bg-purple-500/20 border border-purple-500/25"
                      >
                        {{ marker.name }}
                        <span v-if="marker.visibleToPlayer" class="opacity-80" title="玩家可见">👁</span>
                      </span>
                    </div>
                  </td>
                  <td class="px-2 py-4 max-w-[80px]">
                    <span
                      class="text-gray-500 text-xs truncate block"
                      :title="player.dmNotes || ''"
                    >{{ (player.dmNotes || '').slice(0, 12) }}{{ (player.dmNotes || '').length > 12 ? '…' : '' }}</span>
                  </td>
                  <td class="px-4 py-4">
                    <span
                      v-if="player.dailyConsumptionMet"
                      class="text-green-400 text-sm font-bold"
                      title="已满足当日进食与取暖需求"
                    >✓</span>
                    <span
                      v-else
                      class="text-red-400 text-sm font-bold"
                      title="未满足当日进食与取暖需求"
                    >✗</span>
                  </td>
                  <td class="px-4 py-4">
                    <div class="flex flex-col gap-1.5" :title="tradeBanHint(player)">
                      <label class="inline-flex items-center gap-1.5 cursor-pointer">
                        <input
                          type="checkbox"
                          class="rounded"
                          :checked="player.tradeBanned"
                          :disabled="savingPlayer"
                          @change="toggleTradeBanned(player, $event)"
                        />
                        <span class="text-[10px] text-gray-400 whitespace-nowrap">禁止交易</span>
                        <span
                          v-if="autoTradeBanReasons(player).length"
                          class="text-[10px] text-red-400/80 max-w-[72px] truncate"
                          :title="autoTradeBanReasons(player).join('；')"
                        >{{ autoTradeBanReasons(player).join('；') }}</span>
                      </label>
                      <label class="inline-flex items-center gap-1.5 cursor-pointer">
                        <input
                          type="checkbox"
                          class="rounded"
                          :checked="player.tradeBanExempt"
                          :disabled="savingPlayer"
                          @change="toggleTradeBanExempt(player, $event)"
                        />
                        <span class="text-[10px] text-gray-400 whitespace-nowrap">允许交易（豁免自动禁止）</span>
                      </label>
                    </div>
                  </td>
                  <td class="px-4 py-4">
                    <div class="flex gap-2">
                      <button
                        type="button"
                        class="text-cyan-400 hover:text-cyan-300 text-sm transition-colors"
                        @click="openPlayerInventory(player.id)"
                      >
                        背包
                      </button>
                      <button
                        type="button"
                        class="text-blue-400 hover:text-blue-300 text-sm transition-colors"
                        @click="openEditModal(player)"
                      >
                        编辑
                      </button>
                      <button
                        type="button"
                        class="text-red-400 hover:text-red-300 text-sm transition-colors disabled:opacity-50"
                        :disabled="savingPlayer"
                        @click="handleDelete(player)"
                      >
                        删除
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div
          v-if="showEditModal && editingPlayer"
          class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 overflow-y-auto"
          @click.self="closeEditModal"
        >
          <div class="bg-[#1a2332] border border-white/10 rounded-2xl w-full max-w-lg p-6 shadow-xl my-8" @click.stop>
            <h3 class="text-white text-lg font-medium mb-4">编辑玩家</h3>
            <div class="space-y-4">
              <div>
                <label class="block text-gray-400 text-xs mb-1">姓名</label>
                <input v-model="editingPlayer.name" type="text" class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm" />
              </div>
              <div>
                <label class="block text-gray-400 text-xs mb-1">阵营</label>
                <select v-model="editingPlayer.faction" class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm">
                  <option v-for="f in FACTIONS" :key="f" :value="f">{{ f }}</option>
                </select>
              </div>
              <div>
                <label class="block text-gray-400 text-xs mb-1">职业</label>
                <input
                  v-model="editJobSearch"
                  type="text"
                  placeholder="搜索职业…"
                  class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm mb-1"
                />
                <select
                  v-model="editingPlayer.jobId"
                  class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm"
                  :size="pickerVisibleSize(editJobSearch, filteredEditJobs.length)"
                >
                  <option value="">未分配</option>
                  <option v-for="job in filteredEditJobs" :key="job.id" :value="job.id">{{ job.name }}</option>
                </select>
              </div>
              <div>
                <label class="block text-gray-400 text-xs mb-1">特性</label>
                <input
                  v-model="editSkillSearch"
                  type="text"
                  placeholder="搜索特性…"
                  class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm mb-1"
                />
                <select
                  v-model="editingPlayer.skillId"
                  class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm"
                  :size="pickerVisibleSize(editSkillSearch, filteredEditSkills.length)"
                >
                  <option value="">未分配</option>
                  <option v-for="sk in filteredEditSkills" :key="sk.id" :value="sk.id">{{ sk.name }}</option>
                </select>
              </div>
              <div>
                <label class="block text-gray-400 text-xs mb-1">登录账号</label>
                <input v-model="editingPlayer.loginUsername" type="text" class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm font-mono" />
              </div>
              <div>
                <label class="block text-gray-400 text-xs mb-1">登录密码</label>
                <input v-model="editingPlayer.loginPassword" type="text" class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm font-mono" />
              </div>
              <div class="flex flex-wrap gap-4 text-sm text-gray-300">
                <label class="flex items-center gap-2"><input v-model="editingPlayer.isWeak" type="checkbox" class="rounded" />虚弱</label>
                <label class="flex items-center gap-2"><input v-model="editingPlayer.isOverworked" type="checkbox" class="rounded" />过劳</label>
                <div class="flex flex-col gap-0.5">
                  <label class="flex items-center gap-2"><input v-model="editingPlayer.isBound" type="checkbox" class="rounded" />束缚</label>
                  <p class="text-[10px] text-gray-500">取消勾选将同时移除名称含「束缚」的标记</p>
                </div>
                <label class="flex items-center gap-2">
                  <span class="text-gray-300">身体状态</span>
                  <select v-model.number="editingPlayer.isInjured" class="bg-black/30 border border-white/10 rounded px-2 py-1 text-white text-sm">
                    <option :value="0">未受伤</option>
                    <option :value="1">受伤</option>
                    <option :value="2">重伤</option>
                    <option :value="3">死亡</option>
                  </select>
                </label>
              </div>
              <div>
                <label class="block text-gray-400 text-xs mb-1">隐藏身份（其他玩家不可见）</label>
                <select v-model="editingPlayer.hiddenJobId" class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm">
                  <option value="">无</option>
                  <option v-for="job in hiddenJobs" :key="job.id" :value="job.id">{{ job.name }}</option>
                </select>
              </div>
              <div>
                <label class="block text-gray-400 text-xs mb-1">DM备注（玩家不可见）</label>
                <textarea
                  v-model="editingPlayer.dmNotes"
                  rows="3"
                  class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm resize-y"
                  placeholder="内部备注，例如开局互认地点、飞机残骸位置等"
                />
              </div>
              <div>
                <label class="block text-gray-400 text-xs mb-1">标记</label>
                <div v-if="getPlayerMarkers(editingPlayer.id).length" class="flex flex-wrap gap-1.5 mb-3">
                  <span
                    v-for="marker in getPlayerMarkers(editingPlayer.id)"
                    :key="marker.id"
                    :title="marker.note || marker.name"
                    class="inline-flex items-center gap-1 text-xs px-2 py-1 rounded-full text-purple-300 bg-purple-500/20 border border-purple-500/25"
                  >
                    {{ marker.name }}
                    <span v-if="marker.visibleToPlayer" class="opacity-80" title="玩家可见">👁</span>
                    <button
                      type="button"
                      class="text-purple-200/70 hover:text-white leading-none"
                      :disabled="markerSaving"
                      @click="removePlayerMarker(marker.id)"
                    >
                      ×
                    </button>
                  </span>
                </div>
                <p v-else class="text-gray-600 text-xs mb-2">暂无标记</p>
                <div class="flex flex-wrap gap-2 items-end">
                  <input
                    v-model="markerAddForm.name"
                    type="text"
                    maxlength="50"
                    placeholder="标记名"
                    class="flex-1 min-w-[6rem] bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm"
                  />
                  <input
                    v-model="markerAddForm.note"
                    type="text"
                    maxlength="255"
                    placeholder="备注（可选）"
                    class="flex-1 min-w-[6rem] bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm"
                  />
                  <label class="flex items-center gap-1.5 text-xs text-gray-300 shrink-0 pb-2">
                    <input v-model="markerAddForm.visibleToPlayer" type="checkbox" class="rounded" />
                    玩家可见
                  </label>
                  <button
                    type="button"
                    class="px-3 py-2 bg-purple-600/80 hover:bg-purple-600 text-white text-sm rounded-lg disabled:opacity-50 shrink-0"
                    :disabled="markerSaving || !markerAddForm.name.trim()"
                    @click="addPlayerMarker"
                  >
                    添加
                  </button>
                </div>
              </div>
              <p class="text-gray-500 text-xs">修改背包请使用侧栏「玩家背包」。</p>
            </div>
            <div class="flex justify-end gap-2 mt-6">
              <button type="button" class="px-4 py-2 text-gray-400 rounded-lg hover:bg-white/5" @click="closeEditModal">取消</button>
              <button type="button" class="px-4 py-2 bg-cyan-600 text-white rounded-lg disabled:opacity-50" :disabled="savingPlayer" @click="saveEditPlayer">保存</button>
            </div>
          </div>
        </div>

        <div
          v-if="showCreateModal"
          class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 overflow-y-auto"
          @click.self="closeCreateModal"
        >
          <div class="bg-[#1a2332] border border-white/10 rounded-2xl w-full max-w-2xl p-6 shadow-xl my-8" @click.stop>
            <h3 class="text-white text-lg font-medium mb-4">添加玩家</h3>
            <div class="space-y-4">
              <div>
                <label class="block text-gray-400 text-xs mb-1">姓名</label>
                <input
                  v-model="createForm.name"
                  type="text"
                  :maxlength="PLAYER_NAME_MAX_LENGTH"
                  class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm"
                />
                <p class="text-gray-600 text-xs mt-1">最多 {{ PLAYER_NAME_MAX_LENGTH }} 个字符</p>
              </div>
              <div>
                <label class="block text-gray-400 text-xs mb-2">阵营</label>
                <div class="flex flex-wrap gap-2">
                  <button
                    v-for="f in CREATE_FACTIONS"
                    :key="f"
                    type="button"
                    class="px-3 py-2 rounded-lg text-sm border transition-colors"
                    :class="factionButtonClass(f, createForm.faction === f)"
                    @click="createForm.faction = f"
                  >
                    {{ f }}
                  </button>
                </div>
              </div>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label class="block text-gray-400 text-xs mb-1">职业</label>
                  <input
                    v-model="createJobSearch"
                    type="text"
                    placeholder="搜索职业…"
                    class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm mb-1"
                  />
                  <select
                    v-model="createForm.jobId"
                    class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm"
                    :size="pickerVisibleSize(createJobSearch, filteredCreateJobs.length)"
                  >
                    <option value="" disabled>请选择职业</option>
                    <option v-for="job in filteredCreateJobs" :key="job.id" :value="job.id">{{ job.name }}</option>
                  </select>
                </div>
                <div>
                  <label class="block text-gray-400 text-xs mb-1">特性</label>
                  <input
                    v-model="createSkillSearch"
                    type="text"
                    placeholder="搜索特性…"
                    class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm mb-1"
                  />
                  <select
                    v-model="createForm.skillId"
                    class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm"
                    :size="pickerVisibleSize(createSkillSearch, filteredCreateSkills.length)"
                  >
                    <option value="" disabled>请选择特性</option>
                    <option
                      v-for="sk in filteredCreateSkills"
                      :key="sk.id"
                      :value="sk.id"
                    >
                      {{ sk.name }}
                    </option>
                  </select>
                </div>
              </div>
              <div>
                <label class="block text-gray-400 text-xs mb-1">登录账号</label>
                <input
                  v-model="createForm.loginUsername"
                  type="text"
                  :maxlength="USERNAME_MAX_LENGTH"
                  autocomplete="off"
                  class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm font-mono"
                />
                <p class="text-gray-600 text-xs mt-1">最多 {{ USERNAME_MAX_LENGTH }} 个字符，不可含空格</p>
              </div>
              <div>
                <label class="block text-gray-400 text-xs mb-1">登录密码</label>
                <input
                  v-model="createForm.loginPassword"
                  type="text"
                  :maxlength="PASSWORD_MAX_LENGTH"
                  autocomplete="new-password"
                  class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm font-mono"
                />
                <p class="text-gray-600 text-xs mt-1">最多 {{ PASSWORD_MAX_LENGTH }} 个字符</p>
              </div>
              <div class="flex flex-wrap gap-4 text-sm text-gray-300">
                <label class="flex items-center gap-2"><input v-model="createForm.isWeak" type="checkbox" class="rounded" />虚弱</label>
                <label class="flex items-center gap-2"><input v-model="createForm.isOverworked" type="checkbox" class="rounded" />过劳</label>
                <label class="flex items-center gap-2"><input v-model="createForm.isBound" type="checkbox" class="rounded" />束缚</label>
                <label class="flex items-center gap-2">
                  <span class="text-gray-300">身体状态</span>
                  <select v-model.number="createForm.isInjured" class="bg-black/30 border border-white/10 rounded px-2 py-1 text-white text-sm">
                    <option :value="0">未受伤</option>
                    <option :value="1">受伤</option>
                    <option :value="2">重伤</option>
                    <option :value="3">死亡</option>
                  </select>
                </label>
              </div>
              <div>
                <label class="block text-gray-400 text-xs mb-1">隐藏身份（其他玩家不可见）</label>
                <select
                  v-model="createForm.hiddenJobId"
                  class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm"
                >
                  <option value="">无</option>
                  <option v-for="job in hiddenJobs" :key="job.id" :value="job.id">{{ job.name }}</option>
                </select>
              </div>
              <div>
                <label class="block text-gray-400 text-xs mb-1">DM备注（玩家不可见）</label>
                <textarea
                  v-model="createForm.dmNotes"
                  rows="3"
                  class="w-full bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-white text-sm resize-y"
                  placeholder="内部备注，例如开局互认地点、飞机残骸位置等"
                />
              </div>
              <DmPlayerModalInventory
                ref="createInventoryRef"
                v-model="createStartingItems"
                :job-id="createForm.jobId || null"
                :hidden-job-id="createForm.hiddenJobId || null"
                compact
              />
            </div>
            <div class="flex justify-end gap-2 mt-6">
              <button type="button" class="px-4 py-2 text-gray-400 rounded-lg hover:bg-white/5" @click="closeCreateModal">取消</button>
              <button type="button" class="px-4 py-2 bg-blue-600 text-white rounded-lg disabled:opacity-50" :disabled="savingPlayer" @click="createPlayer">创建</button>
            </div>
          </div>
        </div>
      </div>

      <div v-else-if="activeTab === 'inventories'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <DmPlayerInventoryView
          ref="inventoryViewRef"
          :initial-player-id="inventoryInitialPlayerId"
        />
      </div>

      <div v-else-if="activeTab === 'playerNotebook'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <DmPlayerNotebookView />
      </div>

      <div v-else-if="activeTab === 'ark'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <ArkProgressView embedded />
      </div>

      <div v-else-if="activeTab === 'shelter'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <ShelterProgressView mode="dm" />
      </div>

      <div v-else-if="activeTab === 'trades'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <DmTradesOverview />
      </div>

      <div v-else-if="activeTab === 'milestones'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <div class="mb-6">
          <h1 class="text-white mb-1 tracking-tight text-2xl">里程碑管理</h1>
          <p class="text-gray-500 text-sm">管理反抗者阵营的里程碑进度</p>
        </div>
        <RebelMilestoneView embedded :show-header="false" />
      </div>

      <div v-else-if="activeTab === 'catastrophe'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <CatastrophePanel :is-dm="true" embedded />
      </div>

      <div v-else-if="activeTab === 'warehouse'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <div class="mb-6">
          <h1 class="text-white mb-1 tracking-tight text-2xl">仓库管理</h1>
          <p class="text-gray-500 text-sm">管理所有仓库的物资库存</p>
        </div>
        <WarehouseView />
      </div>

      <div v-else-if="activeTab === 'actionFeedback'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <div class="mb-6">
          <h1 class="text-white mb-1 tracking-tight text-2xl">行动反馈</h1>
          <p class="text-gray-500 text-sm">查看玩家提交的行动并给予反馈</p>
        </div>
        <ActionFeedbackView />
      </div>

      <div v-else-if="activeTab === 'factionActionFeedback'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <FactionActionFeedbackView />
      </div>

      <div v-else-if="activeTab === 'nightActionSettlement'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <NightActionSettlementView />
      </div>

      <div v-else-if="activeTab === 'explorationSettlement'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <DmExplorationSettlementView />
      </div>

      <div v-else-if="activeTab === 'quickInteractionFeedback'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <QuickInteractionFeedbackView />
      </div>

      <div v-else-if="activeTab === 'combatAssist'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <DmCombatAssistView />
      </div>

      <div v-else-if="activeTab === 'settings'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <GameSettingsView />
      </div>

      <div v-else-if="activeTab === 'codex'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <DmItemCodexView />
      </div>

      <div v-else-if="activeTab === 'ruleBook'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <RuleBookView embedded />
      </div>

      <div v-else-if="activeTab === 'logs'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <DmSystemLogView />
      </div>

      <div v-else-if="activeTab === 'endgame'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <EndgameSettlementView />
      </div>

      <div v-else-if="activeTab === 'npc'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <DmNpcManagementView />
      </div>

      <div v-else-if="activeTab === 'reset'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <GameResetView />
      </div>

      <div v-else-if="activeTab === 'game'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <MinesweeperGame />
      </div>

      <!-- Other Tabs -->
      <div v-else style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <p class="text-gray-500 font-normal">功能开发中…</p>
      </div>
      </div>
    </main>
  </div>
</template>
