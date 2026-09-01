<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import MaterialsPanel from './MaterialsPanel.vue'
import PlayerNotebookView from './PlayerNotebookView.vue'
import TradePanel from './TradePanel.vue'
import ArkProgressView from './ArkProgressView.vue'
import ShelterProgressView from './ShelterProgressView.vue'
import ActionSubmitView from './ActionSubmitView.vue'
import FactionActionSubmitView from './FactionActionSubmitView.vue'
import NightActionSubmitView from './NightActionSubmitView.vue'
import QuickInteractionView from './QuickInteractionView.vue'
import RuleBookView from './RuleBookView.vue'
import RebelMilestoneView from './RebelMilestoneView.vue'
import CatastrophePanel from '../components/CatastrophePanel.vue'
import WarehouseView from './WarehouseView.vue'
import PlayerNpcView from './PlayerNpcView.vue'
import MinesweeperGame from './MinesweeperGame.vue'
import SnowEffect from '../components/SnowEffect.vue'
import PlayerTutorialOverlay from '../components/PlayerTutorialOverlay.vue'
import { tradeAPI, playerAPI, milestoneAPI, gameStateAPI, playerConsumptionAPI, loreAPI } from '../utils/api.js'
import { sumPersonalFoodAndFuel, formatKgForDisplay } from '../utils/playerResources.js'
import { getMaterialImageUrlOrDefault } from '../data/gameData.js'
import { useSidebar } from '../composables/useSidebar.js'
import { usePlayerTutorial } from '../composables/usePlayerTutorial.js'

const { collapsed, mobileOpen, isMobile, toggle: toggleSidebar, closeMobile, sidebarVisible } = useSidebar()

const foodIconUrl = getMaterialImageUrlOrDefault('material', 5)
const fuelIconUrl = getMaterialImageUrlOrDefault('material', 8)

const router = useRouter()
const username = localStorage.getItem('username') || ''
const playerId = parseInt(localStorage.getItem('playerId') || '1')
const activeTab = ref('info')

const tradePanelRef = ref(null)

const pendingTradesCount = ref(0)
const loreUnreadCount = ref(0)
const loading = ref(false)
const error = ref(null)
const playerInfo = ref(null)
const gameState = ref({ currentDay: 1, currentPhase: 'DAY' })
const playerItems = ref(null)
const personalResources = ref(null)
const showStatusPopover = ref(false)
const consumptionCtx = ref(null)
const consumptionForm = ref({ foodUnits: 0, woodKg: 0, fuelKg: 0 })
const consumptionSaving = ref(false)
const consumptionMessage = ref(null)
const showOverFuelConfirm = ref(false)

const {
  prompting: tutorialPrompting,
  playing: tutorialPlaying,
  active: tutorialActive,
  currentStep: tutorialStep,
  stepIndex: tutorialStepIndex,
  stepCount: tutorialStepCount,
  isCardStep: tutorialIsCard,
  canPrev: tutorialCanPrev,
  isLast: tutorialIsLast,
  measureGen: tutorialMeasureGen,
  replay: replayTutorial,
  skip: skipTutorial,
  next: nextTutorial,
  prev: prevTutorial,
  tryOfferPrompt: tryOfferTutorial,
  acceptPrompt: acceptTutorial,
  declinePrompt: declineTutorial,
} = usePlayerTutorial({
  playerId,
  getFaction: () => playerInfo.value?.faction || '',
  setTab: (tab) => { activeTab.value = tab },
  collapsed,
  mobileOpen,
  isMobile,
})

/** 仅冒险者可见「方舟建造进度」 */
const showArkTab = computed(() => playerInfo.value?.faction === '冒险者')
/** 仅统治者可见「统治者避难所」 */
const showShelterTab = computed(() => playerInfo.value?.faction === '统治者')
/** 仅反叛者可见「反叛者里程碑」 */
const showMilestoneTab = computed(() => playerInfo.value?.faction === '反叛者')
/** 仅天灾使者可见「天灾降临」 */
const showCatastropheTab = computed(() => playerInfo.value?.faction === '天灾使者')
/** Faction strategic actions — not available to civilians / 外来者 / 原住民 */
const showFactionActionsTab = computed(() => {
  const f = playerInfo.value?.faction
  return f && f !== '平民' && f !== '外来者' && f !== '原住民'
})
/** Night actions — available to all factions including civilians */
const showNightActionsTab = computed(() => {
  const f = playerInfo.value?.faction
  return !!f
})

/** 降雪强度：根据游戏天数决定 */
const snowIntensity = computed(() => {
  const day = gameState.value?.currentDay || 1
  if (day <= 1) return 'light'
  if (day <= 2) return 'medium'
  return 'heavy'
})

watch([showArkTab, showShelterTab, showMilestoneTab, showCatastropheTab, showFactionActionsTab, activeTab], () => {
  if (activeTab.value === 'ark' && !showArkTab.value) activeTab.value = 'info'
  if (activeTab.value === 'shelter' && !showShelterTab.value) activeTab.value = 'info'
  if (activeTab.value === 'milestone' && !showMilestoneTab.value) activeTab.value = 'info'
  if (activeTab.value === 'catastrophe' && !showCatastropheTab.value) activeTab.value = 'info'
  if (activeTab.value === 'factionActions' && !showFactionActionsTab.value) activeTab.value = 'info'
  if (activeTab.value === 'nightActions' && !showNightActionsTab.value) activeTab.value = 'info'
})

let pollTimer = null
let playerInfoRefreshGen = 0

async function refreshLoreUnread() {
  try {
    const userRole = (localStorage.getItem('userRole') || '').toLowerCase()
    const data = await loreAPI.getCatalog(userRole, playerId)
    if (data?.success) {
      loreUnreadCount.value = data.unreadCount || 0
    }
  } catch {
    /* ignore */
  }
}

const fetchPendingTradesCount = async () => {
  try {
    const result = await tradeAPI.getIncomingPendingCount(playerId)
    if (result != null && typeof result.count === 'number') {
      const pendingCount = result.count
      if (pendingCount !== pendingTradesCount.value) {
        pendingTradesCount.value = pendingCount
      }
    }
  } catch (error) {
    console.log('Failed to fetch pending trades:', error.message)
  }
}

const fetchPlayerInfo = async (options) => {
  const silent = options && options.silent === true
  if (!silent) {
    loading.value = true
    error.value = null
  }
  const gen = ++playerInfoRefreshGen
  try {
    const [infoResult, itemsResult, resourcesResult, stateResult] = await Promise.all([
      playerAPI.getDetails(playerId),
      playerAPI.getItems(playerId),
      playerAPI.getResources(playerId),
      gameStateAPI.get().catch(() => null)
    ])

    // Silent polls: drop stale responses if a newer refresh has already started
    if (silent && gen !== playerInfoRefreshGen) {
      return
    }
    
    if (infoResult && infoResult.success) {
      playerInfo.value = infoResult
    } else if (!silent) {
      error.value = infoResult?.message || '获取玩家信息失败'
    }
    
    if (itemsResult && Array.isArray(itemsResult)) {
      playerItems.value = itemsResult
    } else if (!silent) {
      console.log('获取玩家物品失败:', itemsResult?.message)
      playerItems.value = null
    }

    if (stateResult && stateResult.success !== false) {
      gameState.value = {
        currentDay: Number(stateResult.currentDay) || 1,
        currentPhase: stateResult.currentPhase === 'NIGHT' ? 'NIGHT' : 'DAY'
      }
    }

    if (resourcesResult && resourcesResult.success) {
      personalResources.value = resourcesResult
    } else if (!silent) {
      personalResources.value = null
    }

    if (!silent) {
      await fetchConsumption()
    }
  } catch (err) {
    if (!silent) {
      error.value = '网络请求失败，请稍后重试'
    }
    console.error('Failed to fetch player info:', err)
  } finally {
    if (!silent) {
      loading.value = false
    }
  }
}

const fetchGameState = async () => {
  try {
    const stateResult = await gameStateAPI.get()
    if (stateResult && stateResult.success !== false) {
      gameState.value = {
        currentDay: Number(stateResult.currentDay) || 1,
        currentPhase: stateResult.currentPhase === 'NIGHT' ? 'NIGHT' : 'DAY'
      }
    }
  } catch (e) {
    console.log('Failed to fetch game state:', e.message)
  }
}

const startPolling = () => {
  fetchPendingTradesCount()
  refreshLoreUnread()
  fetchGameState()
  pollTimer = setInterval(() => {
    fetchPendingTradesCount()
    refreshLoreUnread()
    fetchPlayerInfo({ silent: true })
  }, 5000)
}

const stopPolling = () => {
  if (pollTimer) {
    clearInterval(pollTimer)
    pollTimer = null
  }
}

const handleTradeTabClick = () => {
  activeTab.value = 'trade'
  fetchPendingTradesCount()
}

const negativeStatuses = computed(() => {
  const p = playerInfo.value
  if (!p) return []
  if (Array.isArray(p.statuses) && p.statuses.length) {
    return p.statuses.map((s) => ({
      name: s.name,
      severity: Math.min(5, Math.max(1, Number(s.severity) || 1)),
      description: s.description
    }))
  }
  const list = []
  if (p.isWeak) {
    list.push({
      name: '虚弱',
      severity: 2,
      description: '你的血肉在低语，诉说着某种迟缓的终结。生产的仪式已非你所能负担，更不必说与阴影中的敌手角力。（无法生产，格斗射击技能无效，可喝酒消除）'
    })
  }
  if (p.isOverworked) {
    list.push({
      name: '过劳',
      severity: 1,
      description: '骨骼在重复的磨损中发出暗哑的呻吟。你知晓那矿洞深处——那该死的避难所残骸——不可再踏足。否则，另一种结局会比夜幕更先降临。（无法执行生产行动，调查玩家和隐匿。在当天夜晚行动和第二天进行需要行动点的生产行动时，投1d6骰子，判定为1则死亡，可使用5瓶朗姆酒消除过劳）'
    })
  }
  const injured = Number(p.isInjured) || 0
  if (injured >= 3) {
    list.push({
      name: '死亡',
      severity: 5,
      description: '天灾的舌锋舔舐过这具躯壳。所有的门扉都已阖上，再无应答。（无额外效果）'
    })
  } else if (injured >= 2) {
    list.push({
      name: '重伤',
      severity: 4,
      description: '你的沙漏已近枯竭。你不知今夜是否便是最后一页。某个披着白袍的影或许能挽留你——又或许，还有另一个……更幽暗的。（无法行动，每夜阶段结束时若不进行急救，则死亡，急救消耗5医疗资源，可将重伤转为受伤）'
    })
  } else if (injured >= 1) {
    list.push({
      name: '受伤',
      severity: 3,
      description: '一道痕迹。它尚未决心吞噬你的命数——至少此刻，它还在犹豫。（你已经受伤了，再次受伤会恶化，无法生产，格斗技能无效）'
    })
  }
  if (p.isBound) {
    list.push({
      name: '束缚',
      severity: 3,
      description: '绳索勒进皮肉，四肢再难听从意志。（无法执行自由行动：生产、调查、隐藏、搬运、战斗等；无法执行夜间行动：密谋、暗杀、探索等；无法使用技能：格斗、射击、潜行等）'
    })
  }
  return list
})

function resetConsumptionForm() {
  consumptionForm.value = { foodUnits: 0, woodKg: 0, fuelKg: 0 }
}

function clampConsumptionInt(field) {
  const n = Math.max(0, Math.floor(Number(consumptionForm.value[field]) || 0))
  if (consumptionForm.value[field] !== n) {
    consumptionForm.value[field] = n
  }
}

async function fetchConsumption() {
  const day = gameState.value.currentDay ?? 1
  try {
    const ctx = await playerConsumptionAPI.getContext(playerId, day)
    if (ctx?.success) {
      consumptionCtx.value = ctx
      resetConsumptionForm()
    }
  } catch (e) {
    console.log('Failed to fetch consumption:', e.message)
  }
}

const consumptionNeedsSubmit = computed(() => {
  const ctx = consumptionCtx.value
  if (!ctx) return false
  return !ctx.foodMet || !ctx.fuelMet
})

const WOOD_HEAT_PER_KG = 1
const FUEL_HEAT_PER_KG = 15

const consumptionHeatingWarning = computed(() => {
  const ctx = consumptionCtx.value
  if (!ctx || ctx.fuelMet === true) return null
  const remaining = Math.max(
    0,
    Number(ctx.remainingFuelKg ?? (ctx.requiredFuelKg - ctx.consumedFuelKg)) || 0
  )
  if (remaining <= 0) return null
  const wood = Math.max(0, Math.floor(Number(consumptionForm.value.woodKg) || 0))
  const fuel = Math.max(0, Math.floor(Number(consumptionForm.value.fuelKg) || 0))
  if (wood === 0 && fuel === 0) return null
  const proposedHeat = wood * WOOD_HEAT_PER_KG + fuel * FUEL_HEAT_PER_KG
  if (proposedHeat <= remaining) return null
  if (fuel > 0) {
    const remainingAfterWood = Math.max(0, remaining - wood * WOOD_HEAT_PER_KG)
    const fuelHeat = fuel * FUEL_HEAT_PER_KG
    if (fuelHeat > remainingAfterWood) {
      return '您投入的燃料将超过当日取暖仍需的热值，属于不必要的额外消耗。1 千克燃料 = 15 热值，请酌情减少燃料或改用木材。'
    }
  }
  return '您投入的取暖物资合计将超过当日仍需的热值。1 千克燃料 = 15 热值，请酌情减少投入。'
})

const consumptionFoodStockWarning = computed(() => {
  const ctx = consumptionCtx.value
  if (!ctx || ctx.foodMet) return null
  const want = Math.max(0, Math.floor(Number(consumptionForm.value.foodUnits) || 0))
  if (want <= 0) return null
  const avail = Number(ctx.availableFoodUnits) || 0
  if (want > avail) {
    return `食物库存不足（库存 ${avail} 单位，本次提交 ${want} 单位）`
  }
  return null
})

const consumptionWoodStockWarning = computed(() => {
  const ctx = consumptionCtx.value
  if (!ctx || ctx.fuelMet) return null
  const want = Math.max(0, Math.floor(Number(consumptionForm.value.woodKg) || 0))
  if (want <= 0) return null
  const avail = Number(ctx.availableWoodKg) || 0
  if (want > avail) {
    return `木材库存不足（库存 ${avail} 千克，本次提交 ${want} 千克）`
  }
  return null
})

const consumptionFuelStockWarning = computed(() => {
  const ctx = consumptionCtx.value
  if (!ctx || ctx.fuelMet) return null
  const want = Math.max(0, Math.floor(Number(consumptionForm.value.fuelKg) || 0))
  if (want <= 0) return null
  const avail = Number(ctx.availableFuelKg) || 0
  if (want > avail) {
    return `燃料库存不足（库存 ${avail} 千克，本次提交 ${want} 千克）`
  }
  return null
})

async function refreshPersonalInventory() {
  try {
    const [itemsResult, resourcesResult] = await Promise.all([
      playerAPI.getItems(playerId),
      playerAPI.getResources(playerId)
    ])
    if (itemsResult && Array.isArray(itemsResult)) {
      playerItems.value = itemsResult
    }
    if (resourcesResult?.success) {
      personalResources.value = resourcesResult
    }
  } catch (e) {
    console.log('Failed to refresh inventory:', e.message)
  }
}

function clearOverFuelConfirmState() {
  showOverFuelConfirm.value = false
}

function clearHeatingFormFields() {
  consumptionForm.value.woodKg = 0
  consumptionForm.value.fuelKg = 0
}

function buildConsumptionPayload(confirmOverFuel = false) {
  clampConsumptionInt('foodUnits')
  clampConsumptionInt('woodKg')
  clampConsumptionInt('fuelKg')
  return {
    playerId,
    gameDay: gameState.value.currentDay ?? 1,
    foodUnits: consumptionForm.value.foodUnits,
    woodKg: consumptionForm.value.woodKg,
    fuelKg: consumptionForm.value.fuelKg,
    confirmOverFuel: confirmOverFuel ? true : undefined
  }
}

async function submitConsumption(confirmOverFuel = false) {
  const ctx = consumptionCtx.value
  const heatingAlreadyMet = ctx?.fuelMet === true
  if (!confirmOverFuel && !heatingAlreadyMet && consumptionHeatingWarning.value) {
    showOverFuelConfirm.value = true
    return
  }
  consumptionSaving.value = true
  consumptionMessage.value = null
  showOverFuelConfirm.value = false
  try {
    const result = await playerConsumptionAPI.submit(buildConsumptionPayload(confirmOverFuel))
    if (result?.success) {
      clearOverFuelConfirmState()
      consumptionCtx.value = result
      consumptionForm.value.foodUnits = 0
      if (result.fuelMet === true) {
        clearHeatingFormFields()
      }
      consumptionMessage.value = { type: 'success', text: result.message || '消耗已记录' }
      await refreshPersonalInventory()
    } else if (result?.needsConfirm && !confirmOverFuel) {
      showOverFuelConfirm.value = true
    } else {
      consumptionMessage.value = { type: 'error', text: result?.message || '提交失败' }
    }
  } catch (e) {
    consumptionMessage.value = { type: 'error', text: '网络请求失败' }
  } finally {
    consumptionSaving.value = false
    if (consumptionCtx.value?.fuelMet === true) {
      clearOverFuelConfirmState()
      clearHeatingFormFields()
    }
  }
}

function cancelOverFuelConfirm() {
  clearOverFuelConfirmState()
}

function confirmOverFuelSubmit() {
  submitConsumption(true)
}

watch(
  () => consumptionCtx.value?.fuelMet,
  (met) => {
    if (met === true) {
      clearOverFuelConfirmState()
      clearHeatingFormFields()
    }
  }
)

const playerResources = computed(() => {
  const api = personalResources.value
  if (api?.success) {
    return {
      food: formatKgForDisplay(api.foodKg ?? 0),
      fuel: formatKgForDisplay(api.fuelKg ?? 0),
      wood: formatKgForDisplay(api.woodKg ?? 0),
      fuelLiters: api.fuelLiters ?? 0
    }
  }
  if (!playerItems.value) {
    return { food: 0, fuel: 0, wood: 0, fuelLiters: 0 }
  }
  const items = Array.isArray(playerItems.value) ? playerItems.value : []
  const totals = sumPersonalFoodAndFuel(items)
  return {
    food: formatKgForDisplay(totals.food),
    fuel: formatKgForDisplay(totals.fuel),
    wood: formatKgForDisplay(totals.wood),
    fuelLiters: 0
  }
})

const dashboardProfile = computed(() => {
  const p = playerInfo.value
  if (!p) return null

  const formatMultiSkillParagraphs = (text) => {
    if (!text || typeof text !== 'string') return text
    // Insert newline after a full stop when the next part looks like "技能名："
    // e.g. "格斗：...。急救：..." -> "格斗：...。\n急救：..."
    return text.replace(/。(?=[^。\n]{1,6}：)/g, '。\n')
  }

  const resources = playerResources.value

  const phaseLabel = gameState.value.currentPhase === 'NIGHT' ? '夜晚' : '白天'

  const dummy = {
    professionalSkillDescription:
      formatMultiSkillParagraphs(p.jobDescription) ||
      p.jobSkills ||
      '拥有深厚的专业知识与实践经验，能够在关键时刻提供高质量的解决方案。（占位文案，可由后端返回替换）',
    traitDescription:
      p.personalSkillFunction ||
      '经历过艰难困苦磨练出的意志与韧性，在逆境下仍能保持行动能力。（占位文案，可由后端返回替换）'
  }

  return {
    name: p.name,
    faction: p.faction || '未设定阵营',
    profession: p.job || '未设定职业',
    negativeStatus: negativeStatuses.value,
    currentDay: gameState.value.currentDay ?? 1,
    currentPhase: phaseLabel,
    foodQuantity: resources.food,
    fuelQuantity: resources.fuel,
    woodFuelQuantity: resources.wood,
    professionalSkill: {
      name: p.jobSkills ? `${p.professionSkill || '职业技能'}` : (p.job ? '职业技能' : '职业技能'),
      description: dummy.professionalSkillDescription
    },
    trait: {
      name: p.personalSkill || '特性',
      description: dummy.traitDescription
    }
  }
})

const handleLogout = () => {
  localStorage.removeItem('userRole')
  localStorage.removeItem('username')
  localStorage.removeItem('playerId')
  router.push('/')
}

watch(activeTab, (tab) => {
  if (tab === 'info' && playerInfo.value && !tutorialActive.value) {
    fetchPlayerInfo()
  }
})

watch([playerInfo, loading, error], () => {
  if (playerInfo.value && !loading.value && !error.value) {
    tryOfferTutorial()
  }
}, { flush: 'post' })

onMounted(() => {
  console.log('Player page mounted, playerId:', playerId)
  fetchPlayerInfo()
  startPolling()
})

onUnmounted(() => {
  stopPolling()
})
</script>

<template>
  <!-- h-screen + overflow-hidden：侧栏固定；仅右侧 main 纵向滚动 -->
  <div
    class="flex h-screen max-h-[100dvh] overflow-hidden bg-[#0a0e1a]"
    :class="{ 'select-none': tutorialActive }"
  >
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
      data-tutorial="hamburger"
      @click="toggleSidebar"
    >
      <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" />
      </svg>
    </button>

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
        <h2 v-if="isMobile || !collapsed" class="text-white tracking-tight text-lg">玩家中心</h2>
        <div v-else class="flex justify-center w-full">
          <span class="text-white text-lg">🎮</span>
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

      <nav
        data-tutorial="sidebar"
        class="min-h-0 flex-1 overflow-y-auto py-2"
        :class="isMobile ? 'p-4' : (collapsed ? 'px-1' : 'p-4')"
      >
        <button
          type="button"
          class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[44px]"
          :class="[
            activeTab === 'info' ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
            (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center'
          ]"
          :title="(!isMobile && collapsed) ? '个人信息' : ''"
          @click="activeTab = 'info'; isMobile && closeMobile()"
        >
          <span v-if="!isMobile && collapsed">👤</span>
          <span v-else>个人信息</span>
        </button>
        <button
          type="button"
          class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[44px]"
          :class="[
            activeTab === 'materials' ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
            (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center'
          ]"
          :title="(!isMobile && collapsed) ? '背包' : ''"
          @click="activeTab = 'materials'; isMobile && closeMobile()"
        >
          <span v-if="!isMobile && collapsed">🎒</span>
          <span v-else>背包</span>
        </button>
        <button
          type="button"
          class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[44px]"
          :class="[
            activeTab === 'notebook' ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
            (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center'
          ]"
          :title="(!isMobile && collapsed) ? '笔记本' : ''"
          @click="activeTab = 'notebook'; isMobile && closeMobile()"
        >
          <span v-if="!isMobile && collapsed">📓</span>
          <span v-else>笔记本</span>
        </button>
        <button
          type="button"
          class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[44px]"
          :class="[
            activeTab === 'actions' ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
            (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center'
          ]"
          :title="(!isMobile && collapsed) ? '个人行动提交' : ''"
          @click="activeTab = 'actions'; isMobile && closeMobile()"
        >
          <span v-if="!isMobile && collapsed">⚔️</span>
          <span v-else>个人行动提交</span>
        </button>
        <button
          v-if="showFactionActionsTab"
          type="button"
          class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[44px]"
          :class="[
            activeTab === 'factionActions' ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
            (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center'
          ]"
          :title="(!isMobile && collapsed) ? '阵营行动提交' : ''"
          @click="activeTab = 'factionActions'; isMobile && closeMobile()"
        >
          <span v-if="!isMobile && collapsed">🏴</span>
          <span v-else>阵营行动提交</span>
        </button>
        <button
          v-if="showNightActionsTab"
          type="button"
          class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[44px]"
          :class="[
            activeTab === 'nightActions' ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
            (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center'
          ]"
          :title="(!isMobile && collapsed) ? '夜晚行动提交' : ''"
          @click="activeTab = 'nightActions'; isMobile && closeMobile()"
        >
          <span v-if="!isMobile && collapsed">🌙</span>
          <span v-else>夜晚行动提交</span>
        </button>
        <button
          type="button"
          class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[44px]"
          :class="[
            activeTab === 'quickInteraction' ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
            (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center'
          ]"
          :title="(!isMobile && collapsed) ? '快速交互' : ''"
          @click="activeTab = 'quickInteraction'; isMobile && closeMobile()"
        >
          <span v-if="!isMobile && collapsed">💬</span>
          <span v-else>快速交互</span>
        </button>
        <button
          v-if="showArkTab"
          type="button"
          class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[44px]"
          :class="[
            activeTab === 'ark' ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
            (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center'
          ]"
          :title="(!isMobile && collapsed) ? '方舟建造进度' : ''"
          @click="activeTab = 'ark'; isMobile && closeMobile()"
        >
          <span v-if="!isMobile && collapsed">🚢</span>
          <span v-else>方舟建造进度</span>
        </button>
        <button
          v-if="showShelterTab"
          type="button"
          class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[44px]"
          :class="[
            activeTab === 'shelter' ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
            (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center'
          ]"
          :title="(!isMobile && collapsed) ? '统治者避难所' : ''"
          @click="activeTab = 'shelter'; isMobile && closeMobile()"
        >
          <span v-if="!isMobile && collapsed">🏠</span>
          <span v-else>统治者避难所</span>
        </button>
        <button
          v-if="showMilestoneTab"
          type="button"
          class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[44px]"
          :class="[
            activeTab === 'milestone' ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
            (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center'
          ]"
          :title="(!isMobile && collapsed) ? '反叛者里程碑' : ''"
          @click="activeTab = 'milestone'; isMobile && closeMobile()"
        >
          <span v-if="!isMobile && collapsed">🏁</span>
          <span v-else>反叛者里程碑</span>
        </button>
        <button
          v-if="showCatastropheTab"
          type="button"
          class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[44px]"
          :class="[
            activeTab === 'catastrophe' ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
            (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center'
          ]"
          :title="(!isMobile && collapsed) ? '天灾降临' : ''"
          @click="activeTab = 'catastrophe'; isMobile && closeMobile()"
        >
          <span v-if="!isMobile && collapsed">⛈️</span>
          <span v-else>天灾降临</span>
        </button>
        <button
          type="button"
          class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[44px]"
          :class="[
            activeTab === 'warehouse' ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
            (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center'
          ]"
          :title="(!isMobile && collapsed) ? '仓库管理' : ''"
          @click="activeTab = 'warehouse'; isMobile && closeMobile()"
        >
          <span v-if="!isMobile && collapsed">📦</span>
          <span v-else>📦 仓库管理</span>
        </button>
        <button
          type="button"
          class="w-full text-left rounded-xl mb-1 transition-colors font-medium relative group min-h-[44px]"
          :class="[
            activeTab === 'trade' ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
            (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center'
          ]"
          :title="(!isMobile && collapsed) ? '交易' : ''"
          @click="handleTradeTabClick(); isMobile && closeMobile()"
        >
          <template v-if="!isMobile && collapsed">
            <span class="relative">🤝
              <span
                v-if="pendingTradesCount > 0"
                class="absolute -top-1 -right-2 bg-red-500 text-white text-[9px] font-bold w-3.5 h-3.5 rounded-full flex items-center justify-center"
              >!</span>
            </span>
          </template>
          <template v-else>
            <span class="flex items-center justify-between">
              <span class="flex items-center gap-2">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
                </svg>
                <span>交易</span>
              </span>
              <span
                v-if="pendingTradesCount > 0"
                class="bg-gradient-to-r from-red-600 to-red-500 text-white text-xs font-bold px-2.5 py-1 rounded-full shadow-lg shadow-red-500/50 animate-pulse min-w-[20px] text-center"
              >
                {{ pendingTradesCount > 9 ? '9+' : pendingTradesCount }}
              </span>
            </span>
          </template>
        </button>
        <button
          type="button"
          class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[44px]"
          :class="[
            activeTab === 'npc' ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
            (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center'
          ]"
          :title="(!isMobile && collapsed) ? 'NPC交互' : ''"
          @click="activeTab = 'npc'; isMobile && closeMobile()"
        >
          <span v-if="!isMobile && collapsed">👥</span>
          <span v-else>NPC 交互</span>
        </button>
        <button
          type="button"
          class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[44px] relative"
          :class="[
            activeTab === 'ruleBook' ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
            (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center'
          ]"
          :title="(!isMobile && collapsed) ? '规则书' : ''"
          @click="activeTab = 'ruleBook'; refreshLoreUnread(); isMobile && closeMobile()"
        >
          <span v-if="!isMobile && collapsed">📖</span>
          <span v-else class="flex items-center gap-2">
            规则书
            <span
              v-if="loreUnreadCount > 0"
              class="min-w-[18px] h-[18px] px-1 rounded-full bg-amber-500 text-black text-[10px] font-bold flex items-center justify-center"
            >
              {{ loreUnreadCount }}
            </span>
          </span>
        </button>
        <button
          type="button"
          class="w-full text-left rounded-xl mb-1 transition-colors font-medium min-h-[44px]"
          :class="[
            activeTab === 'game' ? 'bg-[#2d4263] text-white' : 'text-gray-400 hover:bg-[#151b2e] hover:text-gray-300',
            (isMobile || !collapsed) ? 'px-4 py-3' : 'px-2 py-3 flex items-center justify-center'
          ]"
          :title="(!isMobile && collapsed) ? '小游戏' : ''"
          @click="activeTab = 'game'; isMobile && closeMobile()"
        >
          <span v-if="!isMobile && collapsed">🎮</span>
          <span v-else>小游戏</span>
        </button>
      </nav>

      <div class="shrink-0 border-t border-[#1f2937] p-3">
        <div class="flex items-center" :class="collapsed ? 'flex-col gap-2' : 'justify-between'">
          <span class="text-gray-400 text-sm truncate" :class="collapsed ? 'text-xs' : ''">{{ collapsed ? username.charAt(0) : username }}</span>
          <button
            type="button"
            class="text-gray-500 hover:text-white text-sm transition-colors"
            @click="handleLogout"
          >
            {{ collapsed ? '⏻' : '退出' }}
          </button>
        </div>
      </div>
    </aside>

    <main class="min-h-0 min-w-0 flex-1 overflow-y-auto relative" style="background-image: url('/交互页面背景.png'); background-size: cover; background-position: center; background-repeat: no-repeat;">
      <div class="absolute inset-0 bg-slate-950/10"></div>
      
      <div class="relative z-10 p-4 md:p-8 min-h-full">
      <div
        v-if="activeTab === 'info'"
        class="-m-8 min-h-full p-8"
        style="background: rgba(15, 20, 35, 0.9);"
      >

        <div v-if="loading" class="flex items-center justify-center py-20">
          <div class="text-center">
            <div class="inline-block animate-spin rounded-full h-12 w-12 border-4 border-blue-500 border-t-transparent mb-4"></div>
            <p class="text-gray-400">加载中...</p>
          </div>
        </div>

        <div v-else-if="error" class="bg-red-500/10 border border-red-500/30 rounded-xl p-6 max-w-3xl">
          <div class="flex items-center gap-3 mb-4">
            <svg class="w-6 h-6 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <p class="text-red-400 font-medium">{{ error }}</p>
          </div>
          <button
            @click="fetchPlayerInfo"
            class="px-4 py-2 text-sm text-white bg-red-600 hover:bg-red-700 rounded-lg transition-colors"
          >
            重试
          </button>
        </div>

        <div v-else-if="playerInfo">
          <div v-if="dashboardProfile" class="min-h-full">

                <!-- Header -->
                <div data-tutorial="profile" class="mb-10 relative" style="z-index: 10;">
                  <div class="flex items-end justify-between mb-6 gap-6">
                    <div class="min-w-0">
                      <div class="flex flex-wrap items-center gap-3">
                        <div class="w-full">
                          <div class="text-slate-500 text-xs md:text-sm mb-1 tracking-wider">
                            玩家档案
                          </div>
                        </div>
                        <h2 class="text-4xl md:text-5xl text-white font-bold tracking-tight truncate">
                          {{ dashboardProfile.name }}
                        </h2>

                        <div v-if="dashboardProfile.negativeStatus.length > 0" class="relative inline-block">
                          <button
                            type="button"
                            class="px-3 py-1.5 bg-red-900/40 border border-red-700/50 rounded-lg cursor-pointer transition-all duration-200 hover:bg-red-900/60"
                            @mouseenter="showStatusPopover = true"
                            @mouseleave="showStatusPopover = false"
                            @focus="showStatusPopover = true"
                            @blur="showStatusPopover = false"
                          >
                            <span class="text-red-300 text-xs md:text-sm">
                              负面状态：{{ dashboardProfile.negativeStatus.map(s => s.name).join('、') }}
                            </span>
                          </button>

                          <Transition name="fade-pop">
                            <div
                              v-show="showStatusPopover"
                              class="absolute top-full left-0 mt-2 w-[22rem] md:w-96 bg-slate-900/95 border border-red-700/50 rounded-xl p-4 shadow-2xl will-change-transform transform-gpu"
                              style="z-index: 9999;"
                              @mouseenter="showStatusPopover = true"
                              @mouseleave="showStatusPopover = false"
                            >
                              <h3 class="text-white font-semibold mb-3">负面状态详情</h3>
                              <div class="space-y-3">
                                <div
                                  v-for="(status, idx) in dashboardProfile.negativeStatus"
                                  :key="`${status.name}-${idx}`"
                                  class="bg-slate-800/60 rounded-lg p-3 border border-red-900/30"
                                >
                                  <div class="flex items-center justify-between mb-2">
                                    <span class="text-red-300 font-medium">{{ status.name }}</span>
                                    <div class="flex gap-1">
                                      <span
                                        v-for="i in 3"
                                        :key="i"
                                        :class="['w-2 h-4 rounded-full', i <= status.severity ? 'bg-red-500' : 'bg-slate-600']"
                                      />
                                    </div>
                                  </div>
                                  <p class="text-slate-300 text-sm leading-relaxed">{{ status.description }}</p>
                                </div>
                              </div>
                            </div>
                          </Transition>
                        </div>

                        <div v-else class="relative inline-block">
                          <button
                            type="button"
                            class="px-3 py-1.5 bg-emerald-900/40 border border-emerald-700/50 rounded-lg cursor-pointer transition-all duration-200 hover:bg-emerald-900/60"
                            @mouseenter="showStatusPopover = true"
                            @mouseleave="showStatusPopover = false"
                            @focus="showStatusPopover = true"
                            @blur="showStatusPopover = false"
                          >
                            <span class="text-emerald-300 text-xs md:text-sm">
                              状态：健康
                            </span>
                          </button>

                          <Transition name="fade-pop">
                            <div
                              v-show="showStatusPopover"
                              class="absolute top-full left-0 mt-2 w-[22rem] md:w-96 bg-slate-900/95 border border-emerald-700/50 rounded-xl p-4 shadow-2xl will-change-transform transform-gpu"
                              style="z-index: 9999;"
                              @mouseenter="showStatusPopover = true"
                              @mouseleave="showStatusPopover = false"
                            >
                              <h3 class="text-white font-semibold mb-3">状态详情</h3>
                              <div class="bg-slate-800/60 rounded-lg p-3 border border-emerald-900/30">
                                <div class="flex items-center justify-between mb-2">
                                  <span class="text-emerald-300 font-medium">健康</span>
                                </div>
                                <p class="text-slate-300 text-sm leading-relaxed">健康？不，这只是"尚未被选定"。就像祭坛上那只还未被指尖指向的羔羊，它的平静不值得羡慕。心跳均匀如无人敲击的钟——这种状态不会长久，但它此刻真实得可疑（无负面效果）。</p>
                              </div>
                            </div>
                          </Transition>
                        </div>

                        <div
                          v-if="Array.isArray(playerInfo.markers) && playerInfo.markers.length"
                          class="flex flex-wrap gap-2"
                        >
                          <span
                            v-for="(marker, idx) in playerInfo.markers"
                            :key="`${marker.name}-${idx}`"
                            :title="marker.note || ''"
                            class="px-3 py-1.5 bg-purple-900/40 border border-purple-700/50 rounded-lg text-purple-300 text-xs md:text-sm"
                          >
                            标记：{{ marker.name }}
                          </span>
                        </div>
                      </div>
                    </div>

                    <div class="text-right shrink-0">
                      <div class="flex items-center justify-end gap-2 mb-2 flex-wrap">
                        <button
                          type="button"
                          class="px-3 py-1.5 text-xs md:text-sm text-gray-200 hover:text-white bg-white/5 hover:bg-white/10 rounded-lg transition-colors flex items-center gap-2 will-change-transform transform-gpu disabled:opacity-50"
                          :disabled="tutorialActive"
                          @click="replayTutorial"
                        >
                          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                          </svg>
                          重新观看引导
                        </button>
                        <button
                          type="button"
                          class="px-3 py-1.5 text-xs md:text-sm text-gray-200 hover:text-white bg-white/5 hover:bg-white/10 rounded-lg transition-colors flex items-center gap-2 will-change-transform transform-gpu"
                          @click="fetchPlayerInfo"
                        >
                          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                          </svg>
                          刷新
                        </button>
                      </div>

                      <div class="text-slate-500 text-xs md:text-sm mb-1">游戏进度</div>
                      <div class="text-2xl md:text-3xl text-cyan-300 font-bold">第 {{ dashboardProfile.currentDay }} 天</div>
                      <div v-if="dashboardProfile.currentPhase" class="text-slate-500 text-xs mt-1">{{ dashboardProfile.currentPhase }}</div>
                    </div>
                  </div>
                  <div class="h-1 bg-gradient-to-r from-cyan-500 via-blue-500 to-transparent"></div>
                </div>

                <!-- Main Grid -->
                <div class="grid grid-cols-12 gap-6 md:gap-8">
                  <!-- Left Column -->
                  <div class="col-span-12 lg:col-span-5 space-y-6 md:space-y-8">
                    <!-- Resources -->
                    <div data-tutorial="survival" class="relative group">
                      <div class="absolute inset-0 bg-gradient-to-br from-amber-500/10 to-yellow-500/10 rounded-2xl blur-xl transition-all duration-300 ease-out group-hover:blur-2xl"></div>
                      <div class="relative bg-slate-900/80 border border-slate-700/50 rounded-2xl p-6 transition-all duration-200 ease-out hover:border-amber-500/50 will-change-transform transform-gpu">
                        <div class="text-slate-400 text-xs md:text-sm mb-4 tracking-wider">个人资源</div>
                        <div class="grid grid-cols-2 gap-4">
                          <div class="text-center transition-transform duration-200 ease-out hover:scale-[1.02] will-change-transform transform-gpu">
                            <div class="w-14 h-14 bg-amber-500/20 rounded-lg flex items-center justify-center mx-auto mb-3">
                              <img :src="foodIconUrl" alt="" class="w-10 h-10 object-contain" aria-hidden="true" />
                            </div>
                            <div class="text-slate-400 text-xs mb-1">食物</div>
                            <div class="text-amber-300 text-2xl font-bold">{{ dashboardProfile.foodQuantity }}</div>
                            <div class="text-slate-500 text-xs mt-1">千克</div>
                          </div>
                          <div class="text-center transition-transform duration-200 ease-out hover:scale-[1.02] will-change-transform transform-gpu">
                            <div class="w-14 h-14 bg-yellow-500/20 rounded-lg flex items-center justify-center mx-auto mb-3">
                              <img :src="fuelIconUrl" alt="" class="w-10 h-10 object-contain" aria-hidden="true" />
                            </div>
                            <div class="text-slate-400 text-xs mb-1">燃料</div>
                            <div class="text-amber-300 text-2xl font-bold tabular-nums">{{ dashboardProfile.woodFuelQuantity }}</div>
                            <div class="text-slate-500 text-xs mt-1">千克 木材</div>
                            <p
                              v-if="dashboardProfile.fuelQuantity > 0"
                              class="text-yellow-300/90 text-xs mt-1 tabular-nums"
                            >
                              + {{ dashboardProfile.fuelQuantity }} 千克 燃料
                            </p>
                          </div>
                        </div>

                        <div v-if="consumptionCtx" class="mt-6 pt-5 border-t border-slate-700/50 space-y-4">
                          <div class="text-slate-400 text-xs tracking-wider">进食与生活取暖（第 {{ consumptionCtx.gameDay }} 天）</div>
                          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <div class="rounded-xl bg-slate-800/50 p-4 border border-slate-700/40">
                              <div class="text-slate-400 text-xs mb-2">进食</div>
                              <div class="text-amber-300 text-lg font-bold tabular-nums">
                                {{ consumptionCtx.consumedFoodUnits }} / {{ consumptionCtx.requiredFoodUnits }} 单位
                              </div>
                              <p v-if="consumptionCtx.foodMet" class="text-emerald-400 text-sm font-medium mt-3">已满足</p>
                              <template v-else>
                                <label class="block text-slate-500 text-xs mt-3 mb-1">
                                  本次提交食物（单位，库存 {{ consumptionCtx.availableFoodUnits }}，还需 {{ consumptionCtx.remainingFoodUnits ?? (consumptionCtx.requiredFoodUnits - consumptionCtx.consumedFoodUnits) }}）
                                </label>
                                <input
                                  v-model.number="consumptionForm.foodUnits"
                                  type="number"
                                  min="0"
                                  :max="consumptionCtx.remainingFoodUnits ?? (consumptionCtx.requiredFoodUnits - consumptionCtx.consumedFoodUnits)"
                                  step="1"
                                  inputmode="numeric"
                                  class="w-full bg-slate-900/80 border border-slate-600 rounded-lg px-3 py-2 text-white text-sm tabular-nums"
                                  @input="clampConsumptionInt('foodUnits')"
                                />
                                <p
                                  v-if="consumptionFoodStockWarning"
                                  class="text-red-400 text-xs mt-2 leading-relaxed"
                                >
                                  {{ consumptionFoodStockWarning }}
                                </p>
                              </template>
                            </div>
                            <div class="rounded-xl bg-slate-800/50 p-4 border border-slate-700/40">
                              <div class="text-slate-400 text-xs mb-2">生活取暖</div>
                              <div class="text-yellow-300 text-lg font-bold tabular-nums">
                                {{ consumptionCtx.consumedFuelKg }} / {{ consumptionCtx.requiredFuelKg }} 热值
                              </div>
                              <p v-if="consumptionCtx.fuelMet" class="text-emerald-400 text-sm font-medium mt-3">已满足</p>
                              <template v-else>
                                <label class="block text-slate-500 text-xs mt-3 mb-1">
                                  木材（kg，库存 {{ consumptionCtx.availableWoodKg }}，木材1kg：1热值）
                                </label>
                                <input
                                  v-model.number="consumptionForm.woodKg"
                                  type="number"
                                  min="0"
                                  step="1"
                                  inputmode="numeric"
                                  class="w-full bg-slate-900/80 border border-slate-600 rounded-lg px-3 py-2 text-white text-sm tabular-nums mb-2"
                                  @input="clampConsumptionInt('woodKg')"
                                />
                                <p
                                  v-if="consumptionWoodStockWarning"
                                  class="text-red-400 text-xs mb-2 leading-relaxed"
                                >
                                  {{ consumptionWoodStockWarning }}
                                </p>
                                <label class="block text-slate-500 text-xs mb-1">
                                  燃料（kg，库存 {{ consumptionCtx.availableFuelKg }}，燃料1kg：15热值，取暖还需 {{ consumptionCtx.remainingFuelKg ?? (consumptionCtx.requiredFuelKg - consumptionCtx.consumedFuelKg) }} 热值）
                                </label>
                                <input
                                  v-model.number="consumptionForm.fuelKg"
                                  type="number"
                                  min="0"
                                  step="1"
                                  inputmode="numeric"
                                  class="w-full bg-slate-900/80 border border-slate-600 rounded-lg px-3 py-2 text-white text-sm tabular-nums"
                                  @input="clampConsumptionInt('fuelKg')"
                                />
                                <p
                                  v-if="consumptionFuelStockWarning"
                                  class="text-red-400 text-xs mt-2 leading-relaxed"
                                >
                                  {{ consumptionFuelStockWarning }}
                                </p>
                                <p
                                  v-if="consumptionHeatingWarning"
                                  class="text-amber-300/90 text-xs mt-2 leading-relaxed"
                                >
                                  {{ consumptionHeatingWarning }}
                                </p>
                              </template>
                            </div>
                          </div>
                          <p v-if="!consumptionCtx.requirementsMet" class="text-amber-200/70 text-xs leading-relaxed">
                            {{ consumptionCtx.weakWarning || '若当日未满足进食与取暖需求，次日将陷入「虚弱」状态。' }}
                          </p>
                          <p v-else class="text-emerald-400 text-sm font-medium">当日进食与取暖均已满足。</p>
                          <div v-if="consumptionNeedsSubmit" class="flex flex-wrap items-center gap-3">
                            <button
                              type="button"
                              class="px-4 py-2 rounded-lg bg-cyan-600 hover:bg-cyan-500 text-white text-sm font-medium disabled:opacity-50"
                              :disabled="consumptionSaving"
                              @click="submitConsumption(false)"
                            >
                              {{ consumptionSaving ? '提交中…' : '确认消耗' }}
                            </button>
                            <span v-if="consumptionMessage" :class="consumptionMessage.type === 'success' ? 'text-emerald-400' : 'text-red-400'" class="text-xs">
                              {{ consumptionMessage.text }}
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- Right Column -->
                  <div class="col-span-12 lg:col-span-7 space-y-6 md:space-y-8">
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div class="bg-slate-900/60 border border-slate-700/50 rounded-xl px-5 py-4">
                        <div class="text-slate-400 text-xs tracking-wider mb-1">职业</div>
                        <div class="text-xl md:text-2xl text-white font-bold">{{ dashboardProfile.profession }}</div>
                      </div>
                      <div class="bg-slate-900/60 border border-slate-700/50 rounded-xl px-5 py-4">
                        <div class="text-slate-400 text-xs tracking-wider mb-1">所属阵营</div>
                        <div class="text-xl md:text-2xl text-white font-bold">{{ dashboardProfile.faction }}</div>
                      </div>
                    </div>

                    <!-- Professional Skill -->
                    <div class="relative group">
                      <div class="absolute inset-0 bg-gradient-to-br from-cyan-500/5 to-blue-500/5 rounded-2xl transition-all duration-300 ease-out group-hover:from-cyan-500/10 group-hover:to-blue-500/10"></div>
                      <div class="relative bg-slate-900/60 border-l-4 border-cyan-500 rounded-2xl p-8 md:p-10 transition-all duration-200 ease-out hover:border-cyan-400 will-change-transform transform-gpu">
                        <div class="text-slate-400 text-xs uppercase tracking-wider mb-3">职业技能</div>
                        <h3 class="text-3xl md:text-4xl text-cyan-300 font-bold mb-4">{{ playerInfo.jobSkills || '职业技能' }}</h3>
                        <p class="text-slate-300 text-sm md:text-base leading-relaxed whitespace-pre-line">
                          {{ dashboardProfile.professionalSkill.description }}
                        </p>
                      </div>
                    </div>

                    <!-- Hidden identity (self + DM only) -->
                    <div v-if="playerInfo.hiddenJob" class="relative group">
                      <div class="absolute inset-0 bg-gradient-to-br from-amber-500/5 to-orange-500/5 rounded-2xl transition-all duration-300 ease-out group-hover:from-amber-500/10 group-hover:to-orange-500/10"></div>
                      <div class="relative bg-slate-900/60 border-l-4 border-amber-500 rounded-2xl p-8 md:p-10 transition-all duration-200 ease-out hover:border-amber-400 will-change-transform transform-gpu">
                        <div class="flex flex-wrap items-center gap-2 mb-3">
                          <div class="text-slate-400 text-xs uppercase tracking-wider">隐藏身份 · {{ playerInfo.hiddenJob }}</div>
                          <span class="text-xs px-2 py-0.5 rounded-full bg-amber-500/20 text-amber-300 border border-amber-500/30">仅你自己与主持人可见</span>
                        </div>
                        <h3 class="text-3xl md:text-4xl text-amber-300 font-bold mb-4">{{ playerInfo.hiddenJobSkills || '隐藏技能' }}</h3>
                        <p class="text-slate-300 text-sm md:text-base leading-relaxed whitespace-pre-line">
                          {{ playerInfo.hiddenJobDescription }}
                        </p>
                      </div>
                    </div>

                    <!-- Trait -->
                    <div class="relative group">
                      <div class="absolute inset-0 bg-gradient-to-br from-purple-500/5 to-pink-500/5 rounded-2xl transition-all duration-300 ease-out group-hover:from-purple-500/10 group-hover:to-pink-500/10"></div>
                      <div class="relative bg-slate-900/60 border-l-4 border-purple-500 rounded-2xl p-8 md:p-10 transition-all duration-200 ease-out hover:border-purple-400 will-change-transform transform-gpu">
                        <div class="text-slate-400 text-xs uppercase tracking-wider mb-3">特性</div>
                        <h3 class="text-3xl md:text-4xl text-purple-300 font-bold mb-4">{{ dashboardProfile.trait.name }}</h3>
                        <p class="text-slate-300 text-sm md:text-base leading-relaxed whitespace-pre-line">
                          {{ dashboardProfile.trait.description }}
                        </p>
                      </div>
                    </div>

                    <div class="pt-2">
                      <p class="text-slate-500 text-xs">
                        最后更新: {{ playerInfo.updatedAt ? new Date(playerInfo.updatedAt).toLocaleString('zh-CN') : '未知' }}
                      </p>
                    </div>
                  </div>
                </div>
          </div>
        </div>
      </div>

      <div
        v-else-if="activeTab === 'materials'"
        data-tutorial="materials"
        style="background: rgba(15, 20, 35, 0.9);"
        class="rounded-xl p-6"
      >
        <MaterialsPanel />
      </div>

      <div
        v-else-if="activeTab === 'notebook'"
        data-tutorial="notebook"
        style="background: rgba(15, 20, 35, 0.9);"
        class="rounded-xl p-6"
      >
        <PlayerNotebookView />
      </div>

      <div
        v-else-if="activeTab === 'actions'"
        data-tutorial="actions"
        style="background: rgba(26, 36, 54, 0.94);"
        class="rounded-xl p-6"
      >
        <ActionSubmitView embedded />
      </div>

      <div v-else-if="activeTab === 'factionActions' && showFactionActionsTab" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <FactionActionSubmitView />
      </div>

      <div
        v-else-if="activeTab === 'nightActions' && showNightActionsTab"
        data-tutorial="nightActions"
        style="background: rgba(15, 20, 35, 0.9);"
        class="rounded-xl p-6"
      >
        <NightActionSubmitView />
      </div>

      <div v-else-if="activeTab === 'quickInteraction'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <QuickInteractionView />
      </div>

      <div
        v-else-if="activeTab === 'ruleBook'"
        data-tutorial="ruleBook"
        style="background: rgba(15, 20, 35, 0.9);"
        class="rounded-xl p-6"
      >
        <p
          v-if="loreUnreadCount > 0"
          class="mb-4 text-amber-300/90 text-sm border border-amber-500/30 bg-amber-500/10 rounded-lg px-4 py-2"
        >
          你有 {{ loreUnreadCount }} 份新线索文献，请打开「线索文献」并点击「查看文献」。
        </p>
        <RuleBookView embedded :player-faction="playerInfo?.faction || ''" @lore-unread-updated="(n) => { loreUnreadCount = n }" />
      </div>

      <div
        v-else-if="activeTab === 'ark' && showArkTab"
        data-tutorial="ark"
        style="background: rgba(15, 20, 35, 0.9);"
        class="rounded-xl p-6"
      >
        <ArkProgressView embedded />
      </div>

      <div
        v-else-if="activeTab === 'shelter' && showShelterTab"
        data-tutorial="shelter"
        style="background: rgba(15, 20, 35, 0.9);"
        class="rounded-xl p-6"
      >
        <ShelterProgressView mode="ruler" />
      </div>

      <div
        v-else-if="activeTab === 'milestone' && showMilestoneTab"
        data-tutorial="milestone"
        style="background: rgba(15, 20, 35, 0.9);"
        class="rounded-xl p-6"
      >
        <RebelMilestoneView embedded />
      </div>

      <div
        v-else-if="activeTab === 'catastrophe' && showCatastropheTab"
        data-tutorial="catastrophe"
        style="background: rgba(15, 20, 35, 0.9);"
        class="rounded-xl p-6"
      >
        <CatastrophePanel :is-dm="false" embedded />
      </div>

      <div v-else-if="activeTab === 'warehouse'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <div class="mb-6">
          <h1 class="text-white mb-1 tracking-tight text-2xl">仓库管理</h1>
          <p class="text-gray-500 text-sm">查看和管理您有权限访问的仓库</p>
        </div>
        <WarehouseView />
      </div>

      <div
        v-else-if="activeTab === 'trade'"
        data-tutorial="trade"
        style="background: rgba(15, 20, 35, 0.9);"
        class="rounded-xl p-6"
      >
        <TradePanel ref="tradePanelRef" />
      </div>

      <div
        v-else-if="activeTab === 'npc'"
        data-tutorial="npc"
        style="background: rgba(15, 20, 35, 0.9);"
        class="rounded-xl p-6"
      >
        <PlayerNpcView />
      </div>

      <div v-else-if="activeTab === 'game'" style="background: rgba(15, 20, 35, 0.9);" class="rounded-xl p-6">
        <MinesweeperGame />
      </div>
      </div>
    </main>

    <div
      v-if="showOverFuelConfirm"
      class="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/70"
      @click.self="cancelOverFuelConfirm"
    >
      <div class="bg-slate-900 border border-amber-500/30 rounded-2xl max-w-md w-full p-6 shadow-xl" @click.stop>
        <h3 class="text-white text-lg font-medium mb-2">确认超额取暖消耗？</h3>
        <p class="text-slate-300 text-sm leading-relaxed mb-4">
          {{ consumptionHeatingWarning || '您投入的取暖物资超过当日仍需热值。' }}
          确认后将扣除您填写的全部木材与燃料，生活取暖记为已满足（按所需热值计，不累计超额热值）。
        </p>
        <div class="flex justify-end gap-3">
          <button
            type="button"
            class="px-4 py-2 rounded-lg bg-slate-700 hover:bg-slate-600 text-white text-sm"
            :disabled="consumptionSaving"
            @click="cancelOverFuelConfirm"
          >
            取消
          </button>
          <button
            type="button"
            class="px-4 py-2 rounded-lg bg-amber-600 hover:bg-amber-500 text-white text-sm font-medium disabled:opacity-50"
            :disabled="consumptionSaving"
            @click="confirmOverFuelSubmit"
          >
            {{ consumptionSaving ? '提交中…' : '仍要确认消耗' }}
          </button>
        </div>
      </div>
    </div>

    <PlayerTutorialOverlay
      :prompting="tutorialPrompting"
      :playing="tutorialPlaying"
      :current-step="tutorialStep"
      :step-index="tutorialStepIndex"
      :step-count="tutorialStepCount"
      :is-card-step="tutorialIsCard"
      :can-prev="tutorialCanPrev"
      :is-last="tutorialIsLast"
      :measure-gen="tutorialMeasureGen"
      @skip="skipTutorial"
      @prev="prevTutorial"
      @next="nextTutorial"
      @accept="acceptTutorial"
      @decline="declineTutorial"
    />
  </div>
</template>

<style scoped>
.fade-pop-enter-active,
.fade-pop-leave-active {
  transition: opacity 140ms ease-out, transform 140ms ease-out;
}
.fade-pop-enter-from,
.fade-pop-leave-to {
  opacity: 0;
  transform: translateY(6px) scale(0.99);
}
</style>
