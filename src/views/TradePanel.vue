<script setup>
import { ref, computed, onMounted } from 'vue'
import { playerAPI, tradeAPI } from '../utils/api.js'
import { getMaterialImageUrlOrDefault, NON_TRADABLE_ITEM_IDS } from '../data/gameData.js'

const tradeTypeLabel = (t) =>
  ({
    item: '道具',
    weapon: '武器',
    ammo: '弹药',
    material: '物资'
  }[String(t || '').toLowerCase()] || String(t || ''))

const playerId = parseInt(localStorage.getItem('playerId') || '1')
const currentPlayerName = ref('')
const trades = ref([])
const players = ref([])
const loading = ref(false)
const tradeBanActive = ref(false)
const tradeBanReasons = ref([])

const tradeBanBanner = computed(() => {
  if (!tradeBanActive.value) return ''
  const reasons = tradeBanReasons.value.filter(Boolean)
  return reasons.length ? `禁止交易：${reasons.join('；')}` : '禁止交易'
})

const allMaterialsMap = {
  item: [
    { id: 1, name: '医疗资源', unit: '份', icon: '🏥' },
    { id: 2, name: '手电筒', unit: '个', icon: '🔦' },
    { id: 3, name: '手铐', unit: '个', icon: '⛓️' },
    { id: 4, name: '哨子', unit: '个', icon: '📢' },
    { id: 5, name: '防弹衣', unit: '件', icon: '🛡️' },
    { id: 6, name: '复合盾', unit: '个', icon: '🛡️' },
    { id: 7, name: '信号枪', unit: '把', icon: '🔴' },
    { id: 8, name: '维修工具包', unit: '个', icon: '🔧' },
    { id: 9, name: '协议书', unit: '个', icon: '📜' },
    { id: 10, name: '朗姆酒', unit: '瓶', icon: '🍾' },
    { id: 11, name: '草药', unit: '个', icon: '🌿' },
    { id: 12, name: '渔网', unit: '张', icon: '🎣' },
    { id: 13, name: '蜡烛', unit: '根', icon: '🕯️' },
    { id: 14, name: '医用酒精', unit: '升', icon: '🧪' },
    { id: 15, name: '火柴', unit: '盒', icon: '🔥' },
    { id: 16, name: '铅笔', unit: '盒', icon: '✏️' },
    { id: 17, name: '破损海图', unit: '张', icon: '🗺️' },
    { id: 18, name: '面包', unit: '份', icon: '🍞' },
    { id: 19, name: '仓库钥匙', unit: '把', icon: '🔑' },
    { id: 20, name: '燃料仓库钥匙', unit: '把', icon: '🔑' },
    { id: 21, name: '镇武库钥匙', unit: '把', icon: '🔑' },
    { id: 22, name: '码头集购站钥匙', unit: '把', icon: '🔑' },
    { id: 23, name: '反叛者基地钥匙', unit: '把', icon: '🔑' },
    { id: 24, name: '方舟钥匙', unit: '把', icon: '🔑' },
    { id: 25, name: '火把', unit: '把', icon: '🔥' },
    { id: 26, name: '诅咒硬币', unit: '个', icon: '🪙' },
    { id: 37, name: '尸油蜡烛', unit: '支', icon: '🕯️' },
    { id: 38, name: '深海鱼油蜡烛', unit: '支', icon: '🕯️' },
    { id: 39, name: '旧地图', unit: '张', icon: '🗺️' }
  ],
  weapon: [
    { id: 1, name: '制式手枪', unit: '把', icon: '🔫' },
    { id: 2, name: '猎枪', unit: '把', icon: '🔫' },
    { id: 3, name: '警棍', unit: '把', icon: '⚔️' },
    { id: 4, name: '刺刀', unit: '把', icon: '⚔️' },
    { id: 5, name: '水手刀', unit: '把', icon: '🔪' },
    { id: 6, name: '鱼叉/矛', unit: '个', icon: '⚔️' },
    { id: 7, name: '猎弓', unit: '张', icon: '🏹' },
    { id: 8, name: '十字镐', unit: '把', icon: '⛏️' },
    { id: 9, name: '斧头', unit: '把', icon: '🪓' },
    { id: 10, name: '电锯', unit: '把', icon: '⚙️' },
    { id: 11, name: '手术刀', unit: '把', icon: '🔪' },
    { id: 12, name: '炸药', unit: 'kg', icon: '💣' },
    { id: 13, name: '电钻', unit: '把', icon: '🔧' }
  ],
  ammo: [
    { id: 1, name: '手枪弹', unit: '枚', icon: '🎯' },
    { id: 2, name: '猎枪弹', unit: '枚', icon: '🎯' },
    { id: 3, name: '信号弹', unit: '枚', icon: '🔴' },
    { id: 4, name: '箭矢', unit: '枝', icon: '🎯' }
  ],
  material: [
    { id: 1, name: '金属制品', unit: 'kg', icon: '🔩' },
    { id: 2, name: '木材', unit: 'kg', icon: '🌲' },
    { id: 3, name: '绳索', unit: '米', icon: '🪢' },
    { id: 4, name: '木板', unit: 'kg', icon: '🪵' },
    { id: 6, name: '沥青', unit: 'kg', icon: '🔧' },
    { id: 7, name: '石料', unit: 'kg', icon: '🪨' },
    { id: 9, name: '帆布', unit: '米', icon: '🧵' },
    { id: 10, name: '发动机', unit: '个', icon: '🔧' },
    { id: 11, name: '螺旋桨', unit: '个', icon: '🌀' },
    { id: 12, name: '发电机', unit: '个', icon: '⚡' },
    { id: 13, name: '草木灰', unit: 'kg', icon: '🪨' },
    { id: 5, name: '食物', unit: 'kg', icon: '🍖' },
    { id: 8, name: '燃料', unit: 'kg', icon: '⛽' }
  ]
}

const takePaletteTab = ref('item')
const takePaletteTabs = [
  { key: 'item', label: '道具' },
  { key: 'weapon', label: '武器' },
  { key: 'ammo', label: '弹药' },
  { key: 'material', label: '物资' }
]

const takePaletteRows = (() => {
  const keys = ['item', 'weapon', 'ammo', 'material']
  const o = {}
  for (const type of keys) {
    o[type] = allMaterialsMap[type].map((item) => ({
      ...item,
      itemType: type,
      imageUrl: getMaterialImageUrlOrDefault(type, item.id)
    }))
  }
  return o
})()

const visibleTakePalette = computed(() => takePaletteRows[takePaletteTab.value] || [])

const currentPlayerItems = ref([])

const giveInventoryItemRows = computed(() =>
  currentPlayerItems.value
    .filter((item) => !(item.type === 'item' && NON_TRADABLE_ITEM_IDS.has(item.id)))
    .map((item) => ({
      ...item,
      imageUrl: getMaterialImageUrlOrDefault(item.type, item.id)
    }))
)

const loadCurrentPlayerItems = async () => {
  try {
    const items = await playerAPI.getItems(playerId)
    if (Array.isArray(items) && items.length > 0) {
      currentPlayerItems.value = items.map(item => ({
        id: item.id,
        type: item.type,
        name: item.name,
        unit: item.unit,
        quantity: item.quantity
      }))
    } else {
      currentPlayerItems.value = []
    }
  } catch (error) {
    currentPlayerItems.value = []
  }
}

const otherPlayers = computed(() => {
  return players.value.filter(p => p.id !== playerId)
})

const pendingTradesCount = computed(() => {
  return trades.value.filter(t => t.toPlayerId === playerId && t.status === 'pending').length
})

const incomingTrades = computed(() => {
  return trades.value
    .filter(t => t.toPlayerId === playerId)
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
})

const pendingTrades = computed(() => {
  return incomingTrades.value.filter(t => t.status === 'pending')
})

const showTradeModal = ref(false)
const tradeModalStep = ref(1)
const selectedTargetPlayer = ref('')
const giveItems = ref([])
const takeItems = ref([])
const tradeRemark = ref('')

const showDetailModal = ref(false)
const selectedTrade = ref(null)

const providedItems = computed(() => {
  if (!selectedTrade.value || !selectedTrade.value.items || !Array.isArray(selectedTrade.value.items)) {
    return []
  }
  const fromId = parseInt(selectedTrade.value.fromPlayerId)
  const toId = parseInt(selectedTrade.value.toPlayerId)
  return selectedTrade.value.items.filter(i => {
    const isGive = i.direction === 'give'
    const isTake = i.direction === 'take'
    const isInitiator = fromId === playerId
    const isRecipient = toId === playerId
    return (isInitiator && isGive) || (isRecipient && isTake)
  })
})

const receivedItems = computed(() => {
  if (!selectedTrade.value || !selectedTrade.value.items || !Array.isArray(selectedTrade.value.items)) {
    return []
  }
  const fromId = parseInt(selectedTrade.value.fromPlayerId)
  const toId = parseInt(selectedTrade.value.toPlayerId)
  return selectedTrade.value.items.filter(i => {
    const isGive = i.direction === 'give'
    const isTake = i.direction === 'take'
    const isInitiator = fromId === playerId
    const isRecipient = toId === playerId
    return (isInitiator && isTake) || (isRecipient && isGive)
  })
})

function tradeRowWithThumb(item) {
  const type = item.itemType || 'item'
  const id = item.itemId ?? 1
  return {
    ...item,
    imageUrl: item.imageUrl ?? getMaterialImageUrlOrDefault(type, id)
  }
}

const detailTradeItems = computed(() => {
  const items = selectedTrade.value?.items
  if (!Array.isArray(items)) return []
  return items.map(tradeRowWithThumb)
})

const providedItemsDisplay = computed(() => providedItems.value.map(tradeRowWithThumb))
const receivedItemsDisplay = computed(() => receivedItems.value.map(tradeRowWithThumb))

const isSameTradeEntry = (a, b) => {
  if (!a || !b) return false
  return a.itemType === b.itemType && a.itemId === b.itemId
}

const selectedCountIn = (rows, probe) =>
  rows.reduce((sum, row) => (isSameTradeEntry(row, probe) ? sum + Number(row.quantity || 0) : sum), 0)

const selectedGiveCount = (row) =>
  selectedCountIn(giveItems.value, {
    itemType: row.itemType || row.type,
    itemId: row.id
  })

const selectedTakeCount = (row) =>
  selectedCountIn(takeItems.value, {
    itemType: row.itemType,
    itemId: row.id
  })

const openTradeModal = () => {
  if (tradeBanActive.value) return
  tradeModalStep.value = 1
  showTradeModal.value = true
}

const closeTradeModal = () => {
  tradeModalStep.value = 1
  showTradeModal.value = false
}

const goPreviewStep = () => {
  if (!selectedTargetPlayer.value) {
    alert('请选择交易对象')
    return
  }
  if (giveItems.value.length === 0 && takeItems.value.length === 0) {
    alert('请至少添加一件给予或索取的物品')
    return
  }
  tradeModalStep.value = 2
}

const addGiveItem = (item) => {
  const itemType = item.itemType || item.type
  const itemId = item.id
  const existItem = giveItems.value.find((i) =>
    isSameTradeEntry({ itemType: i.itemType, itemId: i.itemId }, { itemType, itemId })
  )
  if (existItem) {
    if (existItem.quantity < item.quantity) {
      existItem.quantity++
    }
  } else {
    giveItems.value.push({
      itemId,
      itemType,
      name: item.name,
      unit: item.unit,
      imageUrl: item.imageUrl ?? getMaterialImageUrlOrDefault(itemType, item.id),
      quantity: 1,
      maxQuantity: item.quantity
    })
  }
}

const removeGiveItem = (index) => {
  giveItems.value.splice(index, 1)
}

const addTakeItem = (row) => {
  const existItem = takeItems.value.find((i) =>
    isSameTradeEntry(
      { itemType: i.itemType, itemId: i.itemId },
      { itemType: row.itemType, itemId: row.id }
    )
  )
  if (existItem) {
    existItem.quantity = Math.min(500, Number(existItem.quantity || 0) + 1)
  } else {
    takeItems.value.push({
      itemId: row.id,
      itemType: row.itemType,
      name: row.name,
      unit: row.unit,
      imageUrl: row.imageUrl ?? getMaterialImageUrlOrDefault(row.itemType, row.id),
      quantity: 1,
      maxQuantity: 500
    })
  }
}

const removeTakeItem = (index) => {
  takeItems.value.splice(index, 1)
}

const normalizeTakeQuantity = (item) => {
  item.quantity = Math.min(500, Math.max(1, Number(item.quantity || 1)))
}

const sendTrade = async () => {
  if (tradeBanActive.value) return
  if (!selectedTargetPlayer.value) {
    alert('请选择交易对象')
    return
  }
  if (giveItems.value.length === 0 && takeItems.value.length === 0) {
    alert('请至少添加一件给予或索取的物品')
    return
  }

  loading.value = true
  try {
    const items = [
      ...giveItems.value.map(i => ({
        itemType: i.itemType,
        itemId: i.itemId,
        quantity: i.quantity,
        direction: 'give'
      })),
      ...takeItems.value.map(i => ({
        itemType: i.itemType,
        itemId: i.itemId,
        quantity: i.quantity,
        direction: 'take'
      }))
    ]

    const result = await tradeAPI.create({
      fromPlayerId: playerId,
      toPlayerId: parseInt(selectedTargetPlayer.value),
      remark: tradeRemark.value,
      items
    })

    if (result.success) {
      alert('交易请求已发送')
      await loadTrades()
      await loadCurrentPlayerItems()
      selectedTargetPlayer.value = ''
      giveItems.value = []
      takeItems.value = []
      tradeRemark.value = ''
      showTradeModal.value = false
      tradeModalStep.value = 1
    } else {
      alert(result.message || '发送交易失败')
    }
  } catch (error) {
    alert('发送交易失败: ' + error.message)
  } finally {
    loading.value = false
  }
}

const acceptTrade = async (trade) => {
  if (tradeBanActive.value) return
  loading.value = true
  try {
    const result = await tradeAPI.accept(trade.id, playerId)
    if (result.success) {
      alert(result.message || '交易已接受')
      await loadTrades()
    } else {
      alert(result.message || '确认交易失败')
    }
  } catch (error) {
    alert('确认交易失败: ' + error.message)
  } finally {
    loading.value = false
  }
}

const rejectTrade = async (trade) => {
  loading.value = true
  try {
    const result = await tradeAPI.reject(trade.id, playerId)
    if (result.success) {
      alert('交易已拒绝')
      await loadTrades()
    } else {
      alert(result.message || '拒绝交易失败')
    }
  } catch (error) {
    alert('拒绝交易失败: ' + error.message)
  } finally {
    loading.value = false
  }
}

const viewTradeDetail = (trade) => {
  selectedTrade.value = {
    id: trade.id,
    fromPlayerId: trade.fromPlayerId,
    fromPlayerName: trade.fromPlayerName,
    toPlayerId: trade.toPlayerId,
    toPlayerName: trade.toPlayerName || players.value.find(p => p.id === trade.toPlayerId)?.name || '玩家',
    status: trade.status,
    remark: trade.remark,
    createdAt: trade.createdAt,
    items: trade.items || []
  }
  showDetailModal.value = true
}

const closeDetailModal = () => {
  showDetailModal.value = false
  selectedTrade.value = null
}

const loadPlayers = async () => {
  const result = await playerAPI.getAll()
  if (Array.isArray(result)) {
    players.value = result.map(p => ({
      id: p.id,
      name: p.name,
      jobName: p.jobName || null
    }))
  }
}

const loadTradeRestriction = async () => {
  try {
    const details = await playerAPI.getDetails(playerId)
    tradeBanActive.value = Boolean(details?.tradeBanActive)
    tradeBanReasons.value = Array.isArray(details?.tradeBanReasons) ? details.tradeBanReasons : []
  } catch {
    tradeBanActive.value = false
    tradeBanReasons.value = []
  }
}

const loadTrades = async () => {
  try {
    const result = await tradeAPI.getByPlayer(playerId)
    if (Array.isArray(result) && result.length > 0) {
      trades.value = result.map(t => ({
        ...t,
        fromPlayerName: players.value.find(p => p.id === t.fromPlayerId)?.name || '玩家',
        toPlayerName: players.value.find(p => p.id === t.toPlayerId)?.name || '玩家',
        items: t.items || []
      }))
    }
  } catch (error) {
    console.error('加载交易失败:', error)
  }
}

const formatTime = (dateStr) => {
  const date = new Date(dateStr)
  const now = new Date()
  const diff = now - date
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  return `${Math.floor(diff / 86400000)}天前`
}

const getStatusBadge = (status) => {
  const badges = {
    pending: { text: '交易中', color: 'bg-yellow-500/20 text-yellow-400 border-yellow-500/50' },
    accepted: { text: '已接受', color: 'bg-emerald-500/20 text-emerald-400 border-emerald-500/50' },
    rejected: { text: '已拒绝', color: 'bg-red-500/20 text-red-400 border-red-500/50' },
    cancelled: { text: '交易中止', color: 'bg-red-500/20 text-red-400 border-red-500/50' },
    completed: { text: '已接受', color: 'bg-emerald-500/20 text-emerald-400 border-emerald-500/50' }
  }
  return badges[status] || badges.pending
}

onMounted(async () => {
  await loadPlayers()
  await loadTrades()
  await loadCurrentPlayerItems()
  await loadTradeRestriction()
  const currentPlayer = players.value.find(p => p.id === playerId)
  currentPlayerName.value = currentPlayer?.name || ''
})

defineExpose({
  pendingTradesCount
})
</script>

<template>
  <div class="max-w-7xl">
    <div class="mb-6">
      <h1 class="text-white mb-1 tracking-tight text-2xl">交易</h1>
      <p class="text-gray-500 text-sm">Trade Management</p>
    </div>

    <div
      v-if="tradeBanBanner"
      class="mb-6 rounded-xl border border-red-500/40 bg-red-950/50 px-4 py-3 text-red-300 text-sm"
    >
      {{ tradeBanBanner }}
    </div>

    <div class="flex gap-3 mb-6">
      <button
        type="button"
        class="bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white px-5 py-2.5 rounded-xl transition-all text-sm shadow-lg shadow-blue-500/30 flex items-center gap-2 disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:from-blue-500 disabled:hover:to-blue-600"
        :disabled="tradeBanActive"
        @click="openTradeModal"
      >
        <span>发起交易</span>
      </button>
    </div>

    <div v-if="pendingTrades.length > 0" class="mb-8">
      <h2 class="text-white text-lg mb-4 flex items-center gap-2">
        <span class="w-2 h-2 rounded-full bg-blue-400"></span>
        待处理交易
        <span class="text-xs text-gray-400 bg-white/5 px-2 py-1 rounded-full">{{ pendingTrades.length }} 个待审批</span>
      </h2>
      <div class="space-y-4">
        <div
          v-for="trade in pendingTrades"
          :key="trade.id"
          class="relative bg-gradient-to-br from-[#1a2332] to-[#0f1419] border border-white/10 rounded-2xl p-5 overflow-hidden hover:border-white/20 transition-all"
        >
          <div class="absolute top-0 right-0 w-64 h-64 bg-blue-500/5 rounded-full blur-3xl" />
          <div class="relative">
            <div class="flex items-center justify-between mb-4">
              <div class="flex items-center gap-3">
                <div class="w-12 h-12 rounded-xl bg-blue-500/20 flex items-center justify-center text-2xl">👤</div>
                <div>
                  <p class="text-white font-medium">来自 {{ trade.fromPlayerName }}</p>
                  <p class="text-gray-500 text-xs">{{ formatTime(trade.createdAt) }}</p>
                </div>
              </div>
              <div class="flex gap-2">
                <button type="button" class="bg-blue-500/20 hover:bg-blue-500/30 text-blue-400 px-4 py-2 rounded-xl text-sm transition-all" @click="viewTradeDetail(trade)">查看</button>
                <button type="button" class="bg-emerald-500/20 hover:bg-emerald-500/30 text-emerald-400 px-4 py-2 rounded-xl text-sm transition-all disabled:opacity-40 disabled:cursor-not-allowed" @click="acceptTrade(trade)" :disabled="loading || tradeBanActive">接受</button>
                <button type="button" class="bg-red-500/20 hover:bg-red-500/30 text-red-400 px-4 py-2 rounded-xl text-sm transition-all" @click="rejectTrade(trade)" :disabled="loading">拒绝</button>
              </div>
            </div>
            <p v-if="trade.remark" class="text-gray-400 text-sm mb-4">备注：{{ trade.remark }}</p>
          </div>
        </div>
      </div>
    </div>

    <div v-if="trades.length > 0">
      <h2 class="text-white text-lg mb-4 flex items-center gap-2">
        <span class="w-2 h-2 rounded-full bg-gray-400"></span>
        交易记录
      </h2>
      <div class="space-y-3">
        <div
          v-for="trade in trades"
          :key="trade.id"
          class="bg-gradient-to-br from-[#1a2332] to-[#0f1419] border border-white/10 rounded-xl p-4 hover:border-white/20 transition-all"
        >
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-lg bg-white/5 flex items-center justify-center text-lg">👤</div>
              <div>
                <p class="text-gray-200 text-sm">
                  {{ trade.fromPlayerId === playerId ? '向 ' : '来自 ' }}
                  {{ trade.fromPlayerId === playerId ? trade.toPlayerName : trade.fromPlayerName }}
                </p>
                <p class="text-gray-500 text-xs">{{ formatTime(trade.createdAt) }}</p>
              </div>
            </div>
            <div class="flex items-center gap-2">
              <span :class="['text-xs px-3 py-1 rounded-full border', getStatusBadge(trade.status).color]">
                {{ getStatusBadge(trade.status).text }}
              </span>
              <button type="button" class="bg-blue-500/20 hover:bg-blue-500/30 text-blue-400 px-3 py-1.5 rounded-lg text-xs transition-all" @click="viewTradeDetail(trade)">查看</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="trades.length === 0" class="flex flex-col items-center justify-center py-20">
      <div class="w-24 h-24 rounded-full bg-white/5 flex items-center justify-center mb-4">
        <span class="text-4xl">🤝</span>
      </div>
      <h3 class="text-white text-lg mb-2">暂无交易记录</h3>
      <p class="text-gray-500 text-sm">点击"发起交易"开始与他人交易</p>
    </div>

    <Teleport to="body">
      <div v-if="showTradeModal" class="fixed inset-0 bg-black/65 flex items-center justify-center z-50" @click.self="closeTradeModal">
        <div class="bg-gradient-to-br from-[#1a2332] to-[#0f1419] border border-white/10 rounded-3xl p-6 max-w-2xl w-full mx-4 shadow-2xl max-h-[90vh] overflow-y-auto">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-white text-xl tracking-tight">发起交易</h2>
            <button type="button" class="text-gray-400 hover:text-white transition-colors" @click="closeTradeModal">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
            </button>
          </div>

          <div v-if="tradeModalStep === 1" class="space-y-5">
            <div>
              <label class="block text-gray-300 text-sm mb-2">选择交易对象</label>
              <select v-model="selectedTargetPlayer" class="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-gray-200 focus:outline-none focus:border-blue-500/50">
                <option value="">请选择玩家...</option>
                <option v-for="player in otherPlayers" :key="player.id" :value="player.id">{{ player.name }}（{{ player.jobName || '—' }}）</option>
              </select>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div>
                <div class="flex items-center justify-between mb-2">
                  <label class="text-gray-300 text-sm">你提供的物品</label>
                  <span class="text-xs text-gray-500">点击添加</span>
                </div>
                <div class="bg-white/5 border border-white/10 rounded-xl p-3 min-h-[200px] flex flex-col">
                  <div class="text-xs text-gray-500 mb-1">背包物品（点击一行加入）</div>
                  <div class="max-h-56 overflow-y-auto space-y-0.5 mb-3 rounded-lg border border-white/5 p-1 shrink-0">
                    <button
                      v-for="item in giveInventoryItemRows"
                      :key="`give-${item.id}-${item.type}`"
                      type="button"
                      class="w-full flex items-center gap-2 px-2 py-1.5 rounded-md text-xs text-gray-200 hover:bg-white/10 transition-colors text-left"
                      @click="addGiveItem(item)"
                    >
                      <div class="w-8 h-8 shrink-0 rounded-md bg-white/10 overflow-hidden flex items-center justify-center p-0.5">
                        <img :src="item.imageUrl" :alt="item.name" class="w-full h-full object-contain" loading="lazy" decoding="async" />
                      </div>
                      <div class="min-w-0 flex-1">
                        <span class="text-gray-500">[{{ tradeTypeLabel(item.itemType || item.type) }}]</span>
                        {{ item.name }}
                        <span class="text-gray-500"> · {{ item.quantity }}{{ item.unit }}</span>
                      </div>
                      <span v-if="selectedGiveCount(item) > 0" class="text-[11px] text-blue-300 bg-blue-500/20 px-2 py-0.5 rounded-full shrink-0">{{ selectedGiveCount(item) }}</span>
                    </button>
                    <div v-if="giveInventoryItemRows.length === 0" class="text-gray-500 text-xs text-center py-4">暂无背包数据</div>
                  </div>

                  <div class="text-xs text-gray-500 mb-1">已选物品（提供给对方）</div>
                  <div class="space-y-2 flex-1 min-h-0">
                    <div
                      v-for="(item, index) in giveItems"
                      :key="`selected-item-${item.itemType}-${item.itemId}-${index}`"
                      class="bg-white/5 rounded-lg px-2 py-2 flex items-center justify-between gap-2"
                    >
                      <div class="flex items-center gap-2 min-w-0 flex-1">
                        <div class="w-8 h-8 shrink-0 rounded-md bg-white/10 overflow-hidden flex items-center justify-center p-0.5">
                          <img :src="item.imageUrl" :alt="item.name" class="w-full h-full object-contain" decoding="async" />
                        </div>
                        <div class="min-w-0">
                          <span class="text-gray-500 text-xs">[{{ tradeTypeLabel(item.itemType) }}]</span>
                          <span class="text-gray-200 text-sm">{{ item.name }}</span>
                        </div>
                      </div>
                      <div class="flex items-center gap-2">
                        <input v-model.number="item.quantity" type="number" min="1" :max="item.maxQuantity" class="w-16 bg-white/10 rounded px-2 py-1 text-gray-200 text-sm text-center" />
                        <button type="button" class="text-red-400 hover:text-red-300 text-xs" @click="removeGiveItem(giveItems.indexOf(item))">移除</button>
                      </div>
                    </div>
                  </div>
                  <div v-if="giveItems.length === 0" class="text-gray-500 text-sm text-center py-2">暂无选择物品</div>
                </div>
              </div>

              <div>
                <div class="flex items-center justify-between mb-2">
                  <label class="text-gray-300 text-sm">你需要的物品</label>
                  <span class="text-xs text-gray-500">点击添加</span>
                </div>
                <div class="bg-white/5 border border-white/10 rounded-xl p-3 min-h-[200px] flex flex-col">
                  <div class="flex flex-wrap gap-1.5 mb-2 shrink-0">
                    <button
                      v-for="tab in takePaletteTabs"
                      :key="tab.key"
                      type="button"
                      class="px-2.5 py-1 rounded-lg text-xs transition-all border"
                      :class="takePaletteTab === tab.key ? 'bg-blue-500/25 text-blue-300 border-blue-500/40' : 'bg-white/5 text-gray-400 border-transparent hover:bg-white/10'"
                      @click="takePaletteTab = tab.key"
                    >
                      {{ tab.label }}
                    </button>
                  </div>
                  <div class="text-xs text-gray-500 mb-1">图鉴（点击一行加入索取）</div>
                  <div class="max-h-56 overflow-y-auto space-y-0.5 mb-3 rounded-lg border border-white/5 p-1 shrink-0">
                    <button
                      v-for="row in visibleTakePalette"
                      :key="`take-${row.id}-${row.itemType}`"
                      type="button"
                      class="w-full flex items-center gap-2 px-2 py-1.5 rounded-md text-xs text-gray-200 hover:bg-white/10 transition-colors text-left"
                      @click="addTakeItem(row)"
                    >
                      <div class="w-8 h-8 shrink-0 rounded-md bg-white/10 overflow-hidden flex items-center justify-center p-0.5">
                        <img :src="row.imageUrl" :alt="row.name" class="w-full h-full object-contain" loading="lazy" decoding="async" />
                      </div>
                      <div class="min-w-0 flex-1">
                        <span class="text-gray-500">[{{ tradeTypeLabel(row.itemType) }}]</span>
                        {{ row.name }}
                        <span class="text-gray-500"> · {{ row.unit }}</span>
                      </div>
                      <span v-if="selectedTakeCount(row) > 0" class="text-[11px] text-blue-300 bg-blue-500/20 px-2 py-0.5 rounded-full shrink-0">{{ selectedTakeCount(row) }}</span>
                    </button>
                  </div>

                  <div class="text-xs text-gray-500 mb-1">已选物品（向对方索取）</div>
                  <div class="space-y-2 flex-1 min-h-0">
                    <div
                      v-for="(item, index) in takeItems"
                      :key="`selected-take-item-${item.itemType}-${item.itemId}-${index}`"
                      class="bg-white/5 rounded-lg px-2 py-2 flex items-center justify-between gap-2"
                    >
                      <div class="flex items-center gap-2 min-w-0 flex-1">
                        <div class="w-8 h-8 shrink-0 rounded-md bg-white/10 overflow-hidden flex items-center justify-center p-0.5">
                          <img :src="item.imageUrl" :alt="item.name" class="w-full h-full object-contain" decoding="async" />
                        </div>
                        <div class="min-w-0">
                          <span class="text-gray-500 text-xs">[{{ tradeTypeLabel(item.itemType) }}]</span>
                          <span class="text-gray-200 text-sm">{{ item.name }}</span>
                        </div>
                      </div>
                      <div class="flex items-center gap-2">
                        <input v-model.number="item.quantity" type="number" min="1" :max="500" class="w-16 bg-white/10 rounded px-2 py-1 text-gray-200 text-sm text-center" @change="normalizeTakeQuantity(item)" />
                        <button type="button" class="text-red-400 hover:text-red-300 text-xs" @click="removeTakeItem(takeItems.indexOf(item))">移除</button>
                      </div>
                    </div>
                  </div>
                  <div v-if="takeItems.length === 0" class="text-gray-500 text-sm text-center py-2">暂无选择物品</div>
                </div>
              </div>
            </div>

            <div>
              <label class="block text-gray-300 text-sm mb-2">备注信息（可选）</label>
              <textarea v-model="tradeRemark" class="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-gray-200 focus:outline-none focus:border-blue-500/50 resize-none" rows="2" placeholder="添加交易备注..." />
            </div>

            <div class="flex gap-3 pt-2">
              <button type="button" class="flex-1 bg-white/5 hover:bg-white/10 text-gray-300 py-3 rounded-xl transition-all" @click="closeTradeModal">取消</button>
              <button type="button" class="flex-1 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white py-3 rounded-xl transition-all shadow-lg shadow-blue-500/30" @click="goPreviewStep">预览</button>
            </div>
          </div>

          <div v-else class="space-y-5">
            <div class="bg-white/5 border border-white/10 rounded-xl p-4">
              <h3 class="text-gray-300 text-sm mb-2">交易预览</h3>
              <div class="text-xs text-gray-400 mb-1">交易对象：{{ otherPlayers.find(p => p.id === Number(selectedTargetPlayer))?.name || '未选择' }}</div>
              <div class="text-xs text-gray-400 mb-2">你提供 {{ giveItems.length }} 项，索取 {{ takeItems.length }} 项</div>
              <div class="space-y-3 max-h-60 overflow-y-auto">
                <div>
                  <div class="text-[11px] text-gray-500 mb-1">提供</div>
                  <div class="space-y-1">
                    <div v-for="(item, index) in giveItems" :key="`pv-give-${index}`" class="text-xs text-gray-300 flex items-center justify-between">
                      <span>[{{ tradeTypeLabel(item.itemType) }}] {{ item.name }}</span>
                      <span class="text-gray-400">{{ item.quantity }} {{ item.unit }}</span>
                    </div>
                    <div v-if="giveItems.length === 0" class="text-xs text-gray-500">无</div>
                  </div>
                </div>
                <div>
                  <div class="text-[11px] text-gray-500 mb-1">索取</div>
                  <div class="space-y-1">
                    <div v-for="(item, index) in takeItems" :key="`pv-take-${index}`" class="text-xs text-gray-300 flex items-center justify-between">
                      <span>[{{ tradeTypeLabel(item.itemType) }}] {{ item.name }}</span>
                      <span class="text-gray-400">{{ item.quantity }} {{ item.unit }}</span>
                    </div>
                    <div v-if="takeItems.length === 0" class="text-xs text-gray-500">无</div>
                  </div>
                </div>
              </div>
            </div>

            <div v-if="tradeRemark" class="bg-white/5 border border-white/10 rounded-xl p-3">
              <div class="text-xs text-gray-500 mb-1">备注信息</div>
              <p class="text-sm text-gray-300">{{ tradeRemark }}</p>
            </div>

            <div class="flex gap-3 pt-2">
              <button type="button" class="flex-1 bg-white/5 hover:bg-white/10 text-gray-300 py-3 rounded-xl transition-all" @click="tradeModalStep = 1">返回</button>
              <button type="button" class="flex-1 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white py-3 rounded-xl transition-all shadow-lg shadow-blue-500/30" @click="sendTrade" :disabled="loading">发送交易请求</button>
            </div>
          </div>
        </div>
      </div>
    </Teleport>

    <Teleport to="body">
      <div v-if="showDetailModal && selectedTrade" class="fixed inset-0 bg-black/65 flex items-center justify-center z-50" @click.self="closeDetailModal">
        <div class="bg-gradient-to-br from-[#1a2332] to-[#0f1419] border border-white/10 rounded-3xl p-6 max-w-4xl w-full mx-4 shadow-2xl max-h-[90vh] overflow-y-auto">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-white text-xl tracking-tight">交易详情</h2>
            <button type="button" class="text-gray-400 hover:text-white transition-colors" @click="closeDetailModal">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
            </button>
          </div>

          <div class="space-y-6">
            <div class="bg-white/5 backdrop-blur border border-white/10 rounded-xl p-4">
              <h3 class="text-gray-400 text-xs mb-3">基本信息</h3>
              <div class="space-y-3">
                <div class="flex items-center justify-between">
                  <span class="text-gray-500 text-sm">交易对象</span>
                  <span class="text-gray-200 text-sm">
                    {{ selectedTrade.fromPlayerId === playerId ? '向 ' : '来自 ' }}
                    {{ selectedTrade.fromPlayerId === playerId ? selectedTrade.toPlayerName : selectedTrade.fromPlayerName }}
                  </span>
                </div>
                <div class="flex items-center justify-between">
                  <span class="text-gray-500 text-sm">交易状态</span>
                  <span :class="['text-xs px-3 py-1 rounded-full border', getStatusBadge(selectedTrade.status).color]">{{ getStatusBadge(selectedTrade.status).text }}</span>
                </div>
                <div class="flex items-center justify-between">
                  <span class="text-gray-500 text-sm">创建时间</span>
                  <span class="text-gray-200 text-sm">{{ formatTime(selectedTrade.createdAt) }}</span>
                </div>
              </div>
            </div>

            <div class="grid grid-cols-2 gap-3">
              <div class="bg-white/5 backdrop-blur border border-white/10 rounded-xl p-3">
                <h3 class="text-gray-400 text-xs mb-2">你提供</h3>
                <div class="space-y-1 max-h-48 overflow-y-auto">
                  <div
                    v-for="(item, index) in providedItemsDisplay"
                    :key="index"
                    class="flex items-center justify-between gap-2 bg-white/5 rounded-lg px-3 py-2 text-sm"
                  >
                    <span class="flex items-center gap-2 text-gray-200 truncate min-w-0">
                      <span class="w-7 h-7 shrink-0 rounded bg-white/10 overflow-hidden flex items-center justify-center p-0.5">
                        <img :src="item.imageUrl" :alt="item.name" class="w-full h-full object-contain" decoding="async" />
                      </span>
                      <span class="truncate">[{{ tradeTypeLabel(item.itemType) }}] {{ item.name }}</span>
                    </span>
                    <span class="text-gray-400 shrink-0 whitespace-nowrap">{{ item.quantity }} {{ item.unit }}</span>
                  </div>
                  <div v-if="providedItemsDisplay.length === 0" class="text-gray-500 text-sm text-center py-4">无</div>
                </div>
              </div>

              <div class="bg-white/5 backdrop-blur border border-white/10 rounded-xl p-3">
                <h3 class="text-gray-400 text-xs mb-2">你获得</h3>
                <div class="space-y-1 max-h-48 overflow-y-auto">
                  <div
                    v-for="(item, index) in receivedItemsDisplay"
                    :key="index"
                    class="flex items-center justify-between gap-2 bg-white/5 rounded-lg px-3 py-2 text-sm"
                  >
                    <span class="flex items-center gap-2 text-gray-200 truncate min-w-0">
                      <span class="w-7 h-7 shrink-0 rounded bg-white/10 overflow-hidden flex items-center justify-center p-0.5">
                        <img :src="item.imageUrl" :alt="item.name" class="w-full h-full object-contain" decoding="async" />
                      </span>
                      <span class="truncate">[{{ tradeTypeLabel(item.itemType) }}] {{ item.name }}</span>
                    </span>
                    <span class="text-gray-400 shrink-0 whitespace-nowrap">{{ item.quantity }} {{ item.unit }}</span>
                  </div>
                  <div v-if="receivedItemsDisplay.length === 0" class="text-gray-500 text-sm text-center py-4">无</div>
                </div>
              </div>
            </div>

            <div v-if="selectedTrade.remark" class="bg-white/5 backdrop-blur border border-white/10 rounded-xl p-4">
              <h3 class="text-gray-400 text-xs mb-2">备注信息</h3>
              <p class="text-gray-300 text-sm">{{ selectedTrade.remark }}</p>
            </div>

            <div v-if="selectedTrade.status === 'pending' && selectedTrade.toPlayerId === playerId" class="flex gap-3">
              <button type="button" class="flex-1 bg-white/5 hover:bg-white/10 text-gray-300 py-3 rounded-xl transition-all" @click="closeDetailModal">关闭</button>
              <button type="button" class="flex-1 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white py-3 rounded-xl transition-all shadow-lg shadow-blue-500/30" @click="closeDetailModal">继续操作</button>
            </div>
            <div v-else class="flex justify-center">
              <button type="button" class="w-full bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white py-3 rounded-xl transition-all shadow-lg shadow-blue-500/30" @click="closeDetailModal">关闭</button>
            </div>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>
