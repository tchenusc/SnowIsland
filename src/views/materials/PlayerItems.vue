<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { playerAPI } from '../../utils/api.js'

const items = ref([])
const loading = ref(true)
const playerId = localStorage.getItem('playerId') || '1'

const loadItems = async () => {
  loading.value = true
  try {
    const result = await playerAPI.getItems(playerId)
    if (Array.isArray(result)) {
      items.value = result.filter(item => item.type === 'item').map(item => ({
        id: item.id,
        name: item.name,
        unit: item.unit,
        quantity: item.quantity,
        icon: getIconByType('item'),
        // 数据库 remark 为真相；本地映射仅作缺省回退
        remark: item.remark || getRemarkByItem(item.id)
      }))
      console.log('Items refreshed:', items.value.length, 'items')
    }
  } catch (error) {
    console.error('Failed to load items:', error)
  } finally {
    loading.value = false
  }
}

const getIconByType = (type) => {
  const icons = {
    item: '📦',
    weapon: '⚔️',
    ammo: '🎯',
    material: '🔧'
  }
  return icons[type] || '📦'
}

const getRemarkByItem = (itemId) => {
  const remarks = {
    1: '基础医疗物资，急救重伤需5份',
    2: '提供光源',
    3: '限制行动',
    4: '发出信号',
    5: '重伤降级或受伤无效',
    6: '提供防护',
    7: '发射信号',
    8: '修复物品',
    9: '交易凭证',
    10: '恢复精力',
    11: '医疗材料',
    12: '捕鱼工具',
    13: '照明工具',
    14: '消毒用品',
    15: '点火工具',
    16: '书写工具',
    17: '导航工具',
    18: '额外白天行动点',
    19: '仓库通行',
    20: '燃料仓库通行',
    21: '镇武库通行',
    22: '码头集购站通行',
    23: '反叛者基地通行',
    24: '方舟通行',
    25: '夜间照明取暖与探索',
    26: '无法丢弃的神秘硬币',
    27: '泛着微光的奇异石头，似乎蕴含某种能量',
    28: '古旧笔记，可借助举行某种仪式',
    29: '发出微弱脉动光的矿石碎片',
    30: '覆盖细密鳞片的外套，不可交易',
    31: '记载古老契约条款的铁卷',
    32: '潦草但充满力量的革命宣言',
    33: '标注龙骨结构与符文的羊皮纸',
    34: '被烧过但仍可读的预言书',
    35: '记载禁忌内容的册子残页',
    36: '记录星轨与星象的手稿',
    37: '燃烧时散发奇异气味的蜡烛',
    38: '深海鱼油制成，火焰呈幽蓝色',
    39: '标注某地点大致位置的残旧地图',
    40: '保存完好的飞机金属油箱',
    41: '结构完整的飞机起落架组件',
    42: '可书写记录的笔记本，不可交易',
    43: '可正常书写的钢笔，不可交易',
    44: '刻满螺旋纹路的青铜罗盘',
    45: '鲸骨刻刀，刀柄镶嵌石化鱼眼珠',
    46: '内部有暗红雾气的黑色玻璃球',
    47: '三足青铜烛台，底座刻扭曲符文',
    48: '黑曜石圆盘，刻黄道十二宫符号',
    49: '烧不尽一半的旗帜',
    50: '刻着衔尾蛇图案的旧银币，握在手中刺骨冰凉',
    51: '半头盔式情绪抑制装置，装备后获得情绪抑制状态，直到主动解除或损坏',
    52: '深灰色卵石，可感知约200米内地脉异常；每2天一次，用后眩晕检定-1',
    53: '铁砧小队记录员莉迪亚的残卷笔记',
    54: '飞机副驾驶座组件，可以安装使用'
  }
  return remarks[itemId] || '道具'
}

const handleVisibilityChange = () => {
  if (!document.hidden) {
    console.log('Page visible, refreshing items...')
    loadItems()
  }
}

onMounted(() => {
  loadItems()
  document.addEventListener('visibilitychange', handleVisibilityChange)
  console.log('Player items component mounted', { playerId })
})

onUnmounted(() => {
  document.removeEventListener('visibilitychange', handleVisibilityChange)
})

defineExpose({ refresh: loadItems })
</script>

<template>
  <div class="max-w-6xl">
    <div class="mb-6">
      <h1 class="text-white mb-1 tracking-tight text-2xl">道具管理</h1>
      <p class="text-gray-500 text-sm">Items & Equipment</p>
    </div>

    <div v-if="items.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <div
        v-for="item in items"
        :key="item.id"
        class="relative bg-gradient-to-br from-[#1a2332] to-[#0f1419] border border-white/10 rounded-2xl p-5 overflow-hidden hover:border-white/20 transition-all"
      >
        <div class="absolute top-0 right-0 w-32 h-32 bg-blue-500/5 rounded-full blur-2xl" />
        
        <div class="relative flex items-start gap-4">
          <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-blue-400/20 to-blue-500/20 flex items-center justify-center text-2xl flex-shrink-0">
            {{ item.icon }}
          </div>
          
          <div class="flex-1 min-w-0">
            <div class="flex items-center justify-between mb-1">
              <h3 class="text-white font-medium truncate">{{ item.name }}</h3>
              <span class="text-xs text-gray-400 bg-white/5 px-2 py-1 rounded-full">{{ item.unit }}</span>
            </div>
            
            <p class="text-gray-400 text-sm mb-3">{{ item.remark }}</p>
            
            <div class="flex items-center gap-2">
              <span class="text-xs text-gray-500">数量</span>
              <span class="text-lg font-semibold text-blue-400">{{ item.quantity }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="flex flex-col items-center justify-center py-20">
      <div class="w-24 h-24 rounded-full bg-white/5 flex items-center justify-center mb-4">
        <span class="text-4xl">📦</span>
      </div>
      <h3 class="text-white text-lg mb-2">暂无道具</h3>
      <p class="text-gray-500 text-sm">您当前没有该类别的物资</p>
    </div>
  </div>
</template>
