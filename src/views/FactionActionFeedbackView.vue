<script setup>
import { ref, computed, onMounted } from 'vue'
import { factionActionAPI } from '@/utils/api.js'
import { useGameDayScope } from '@/composables/useGameDayScope.js'
import { FACTION_LABELS, GM_FACTION_TABS, PAYLOAD_FIELD_LABELS } from '@/data/factionActions.js'

const actions = ref([])
const { currentGameDay, dayOptions, loadGameState } = useGameDayScope()
const loading = ref(true)
const filterGameDay = ref('1')
const filterFaction = ref('')
const filterStatus = ref('')
const feedbackText = ref('')
const selectedActionId = ref(null)
const toast = ref(null)

const statusOptions = [
  { value: '', label: '全部状态' },
  { value: 'pending', label: '待反馈' },
  { value: 'feedbacked', label: '已反馈' },
]

const filteredActions = computed(() => (Array.isArray(actions.value) ? actions.value : []))
const pendingCount = computed(() => actions.value.filter(a => a.status === 'pending').length)

const resolving = ref(false)
const publishing = ref(false)

function extraLaborActions() {
  return (actions.value || []).filter((a) => a.actionType === 'extra_labor')
}

const extraLaborPendingCount = computed(() =>
  extraLaborActions().filter((a) => a.extraLaborPending).length
)

const extraLaborUnsettledCount = computed(() =>
  extraLaborActions().filter((a) => !a.extraLaborPending && !a.extraLaborDispatched).length
)

async function resolveExtraLabor() {
  resolving.value = true
  try {
    const res = await factionActionAPI.resolveExtraLabor(parseInt(filterGameDay.value, 10))
    const errs = Array.isArray(res?.errors) ? res.errors.filter(Boolean) : []
    showToast(res?.success && errs.length === 0 ? 'success' : 'error', res?.message || '结算失败')
    await fetchActions()
  } catch {
    showToast('error', '额外劳动结算异常')
  } finally {
    resolving.value = false
  }
}

async function publishExtraLabor() {
  if (publishing.value) return
  if (!confirm(`确定发布第 ${filterGameDay.value} 天的额外劳动物资？确认后才会发放到玩家背包。`)) return
  publishing.value = true
  try {
    const res = await factionActionAPI.publishExtraLabor(parseInt(filterGameDay.value, 10))
    const errs = Array.isArray(res?.errors) ? res.errors.filter(Boolean) : []
    showToast(res?.success && errs.length === 0 ? 'success' : 'error', res?.message || '发布失败')
    await fetchActions()
  } catch {
    showToast('error', '额外劳动发布异常')
  } finally {
    publishing.value = false
  }
}

async function fetchActions() {
  loading.value = true
  try {
    const params = {}
    if (filterGameDay.value) params.gameDay = filterGameDay.value
    if (filterFaction.value) params.faction = filterFaction.value
    if (filterStatus.value) params.status = filterStatus.value
    const result = await factionActionAPI.getAllActions(params)
    actions.value = Array.isArray(result) ? result : []
  } catch (e) {
    actions.value = []
  } finally {
    loading.value = false
  }
}

async function submitFeedback() {
  if (!selectedActionId.value || !feedbackText.value.trim()) return
  try {
    const res = await factionActionAPI.feedbackAction(selectedActionId.value, feedbackText.value.trim())
    if (res?.success) {
      feedbackText.value = ''
      selectedActionId.value = null
      showToast('success', '反馈已保存')
      await fetchActions()
    } else {
      showToast('error', res?.message || '反馈失败')
    }
  } catch (e) {
    showToast('error', '反馈提交异常')
  }
}

function showToast(type, text) {
  toast.value = { type, text }
  setTimeout(() => { toast.value = null }, 3500)
}

function formatPayload(payload) {
  if (!payload || typeof payload !== 'object') return ''
  return Object.entries(payload)
    .filter(([, v]) => v != null && v !== '')
    .map(([k, v]) => {
      const label = PAYLOAD_FIELD_LABELS[k] || k
      const val = Array.isArray(v) ? v.join('、') : (v === true ? '是' : v === false ? '否' : v)
      return `${label}：${val}`
    })
    .join('\n')
}

function isNpcAssignPersonnel(action) {
  return action?.actionType === 'assign_personnel' && action?.payload?.targetKind === 'npc'
}

function npcAutoVerdictBadge(action) {
  const r = action?.result || ''
  if (r.includes('已全部自动执行')) {
    return { text: '已自动结算', cls: 'bg-emerald-500/20 text-emerald-400 border-emerald-500/30' }
  }
  if (r.includes('部分自动执行，其余待主持人裁定')) {
    return { text: '部分自动·待裁定', cls: 'bg-cyan-500/20 text-cyan-300 border-cyan-500/30' }
  }
  if (r.includes('结论：NPC拒绝执行')) {
    return { text: 'NPC拒绝', cls: 'bg-red-500/20 text-red-400 border-red-500/30' }
  }
  if (r.includes('结论：无法执行')) {
    return { text: '无法执行', cls: 'bg-gray-500/20 text-gray-400 border-gray-500/30' }
  }
  return null
}

function shouldShowRawPayload(action) {
  if (action?.actionType === 'assign_personnel' && action?.result) return false
  return !!(action?.payload && Object.keys(action.payload).length)
}

onMounted(async () => {
  await loadGameState()
  filterGameDay.value = String(currentGameDay.value || 1)
  await fetchActions()
})
</script>

<template>
  <div>
      <div class="text-center mb-8">
        <h1 class="text-white text-2xl md:text-3xl font-semibold tracking-tight mb-2">阵营行动反馈</h1>
        <p class="text-gray-500 text-sm">查看玩家提交的阵营行动并给予反馈</p>
      </div>

      <div class="bg-gradient-to-br from-[#1a2332] to-[#0f1419] border border-white/10 rounded-2xl p-5 mb-6">
        <div class="flex flex-wrap gap-3 items-end">
          <div>
            <label class="block text-gray-500 text-xs mb-1.5">天数</label>
            <select v-model="filterGameDay" class="filter-select" @change="fetchActions">
              <option v-for="d in dayOptions" :key="d" :value="String(d)">
                第{{ d }}天{{ d === currentGameDay ? '（当前）' : '' }}
              </option>
            </select>
          </div>
          <div>
            <label class="block text-gray-500 text-xs mb-1.5">阵营</label>
            <select v-model="filterFaction" class="filter-select" @change="fetchActions">
              <option value="">全部阵营</option>
              <option v-for="f in GM_FACTION_TABS" :key="f" :value="f">{{ FACTION_LABELS[f]?.label || f }}</option>
            </select>
          </div>
          <div>
            <label class="block text-gray-500 text-xs mb-1.5">状态</label>
            <select v-model="filterStatus" class="filter-select" @change="fetchActions">
              <option v-for="opt in statusOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
            </select>
          </div>
        </div>
        <p class="text-xs text-gray-500 mt-3">
          待反馈：<span class="text-amber-400 font-medium">{{ pendingCount }}</span>
          <span class="mx-2">·</span>
          额外劳动待结算：<span class="text-cyan-400 font-medium">{{ extraLaborUnsettledCount }}</span>
          <span class="mx-2">·</span>
          额外劳动待发布：<span class="text-cyan-400 font-medium">{{ extraLaborPendingCount }}</span>
        </p>
        <p class="text-xs text-gray-600 mt-2">
          额外劳动：先结算算出 +50% 产出，发布后才发放到背包。也可在「行动反馈」用一键结算 / 发布反馈一并处理。
        </p>
        <div class="flex flex-wrap gap-2 mt-3">
          <button
            type="button"
            class="px-3 py-1.5 text-xs rounded-lg bg-cyan-600/20 text-cyan-300 border border-cyan-500/30 hover:bg-cyan-600/30 disabled:opacity-50"
            :disabled="resolving"
            @click="resolveExtraLabor"
          >
            {{ resolving ? '结算中…' : '结算额外劳动' }}
          </button>
          <button
            type="button"
            class="px-3 py-1.5 text-xs rounded-lg bg-emerald-600/20 text-emerald-300 border border-emerald-500/30 hover:bg-emerald-600/30 disabled:opacity-50"
            :disabled="publishing || extraLaborPendingCount === 0"
            @click="publishExtraLabor"
          >
            {{ publishing ? '发布中…' : '发布额外劳动物资' }}
          </button>
        </div>
      </div>

      <div v-if="loading" class="flex justify-center py-20">
        <div class="w-12 h-12 border-4 border-blue-500 border-t-transparent rounded-full animate-spin" />
      </div>

      <div v-else-if="filteredActions.length === 0" class="text-center py-20 text-gray-500">暂无阵营行动记录</div>

      <div v-else class="space-y-4">
        <div
          v-for="action in filteredActions"
          :key="action.id"
          class="bg-gradient-to-br from-[#1a2332] to-[#0f1419] border border-white/10 rounded-2xl p-5"
          :class="{ 'ring-1 ring-cyan-500/30': selectedActionId === action.id }"
        >
          <div class="flex flex-wrap items-center gap-2 mb-3">
            <span class="text-white font-medium text-sm">{{ action.playerName }}</span>
            <span class="text-xs px-2 py-0.5 rounded-full border" :class="FACTION_LABELS[action.faction]?.color || 'bg-white/10 text-gray-400'">
              {{ FACTION_LABELS[action.faction]?.label || action.faction }}
            </span>
            <span class="text-xs px-2 py-0.5 rounded-full bg-white/10 text-gray-300">{{ action.actionTypeLabel }}</span>
            <span
              v-if="isNpcAssignPersonnel(action)"
              class="text-xs px-2 py-0.5 rounded-full bg-amber-500/20 text-amber-400 border border-amber-500/30"
            >NPC行动</span>
            <span
              v-if="npcAutoVerdictBadge(action)"
              class="text-xs px-2 py-0.5 rounded-full border"
              :class="npcAutoVerdictBadge(action).cls"
            >{{ npcAutoVerdictBadge(action).text }}</span>
            <span class="text-gray-600 text-xs">第{{ action.gameDay }}天</span>
            <span
              class="ml-auto text-xs px-2 py-0.5 rounded-full"
              :class="action.extraLaborDispatched
                ? 'bg-green-500/20 text-green-400'
                : action.extraLaborPending
                  ? 'bg-cyan-500/20 text-cyan-400'
                  : action.status === 'pending' ? 'bg-amber-500/20 text-amber-400' : 'bg-green-500/20 text-green-400'"
            >
              {{ action.extraLaborDispatched ? '已发放' : action.extraLaborPending ? '待发布' : (action.status === 'pending' ? '待反馈' : '已反馈') }}
            </span>
          </div>

          <pre v-if="shouldShowRawPayload(action)" class="text-gray-500 text-xs mb-2 whitespace-pre-wrap font-sans">输入详情：
{{ formatPayload(action.payload) }}</pre>

          <div v-if="action.result" class="text-gray-300 text-sm whitespace-pre-wrap bg-black/20 rounded-xl p-4 mb-3 border border-white/5">
            {{ action.result }}
          </div>

          <div v-if="action.status === 'pending'" class="flex gap-2">
            <button
              type="button"
              class="px-4 py-1.5 bg-cyan-600/20 text-cyan-400 border border-cyan-500/30 rounded-lg text-sm hover:bg-cyan-600/30"
              @click="selectedActionId = action.id; feedbackText = ''"
            >
              {{ selectedActionId === action.id ? '编辑反馈中...' : '给予反馈' }}
            </button>
          </div>

          <div v-if="selectedActionId === action.id" class="mt-3 pt-3 border-t border-white/10">
            <textarea v-model="feedbackText" rows="3" placeholder="输入反馈内容..." class="w-full resize-none bg-black/30 border border-white/10 rounded-xl px-4 py-3 text-sm text-gray-200 mb-2 focus:outline-none focus:border-cyan-500/50" />
            <div class="flex gap-2">
              <button type="button" class="px-4 py-1.5 bg-cyan-600 text-white rounded-lg text-sm" @click="submitFeedback">提交反馈</button>
              <button type="button" class="px-4 py-1.5 bg-white/5 text-gray-400 rounded-lg text-sm" @click="selectedActionId = null; feedbackText = ''">取消</button>
            </div>
          </div>
        </div>
      </div>

      <div v-if="toast" class="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 px-5 py-2.5 rounded-xl text-sm text-white" :class="toast.type === 'success' ? 'bg-green-600' : 'bg-red-600'">
        {{ toast.text }}
      </div>
  </div>
</template>

<style scoped>
.filter-select {
  @apply bg-black/30 border border-white/10 rounded-lg px-3 py-2 text-sm text-gray-200 focus:outline-none;
}
</style>
