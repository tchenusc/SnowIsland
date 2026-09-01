<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { playerAPI } from '../utils/api.js'
import { getMaterialImageUrlOrDefault, getTypeTabImage } from '../data/gameData.js'
import ShelterSupplyCards from './ShelterSupplyCards.vue'

const playerId = localStorage.getItem('playerId') || '1'
const loading = ref(true)
const rawMaterials = ref([])
const foodSupply = ref({ totalKg: 0, items: [] })
const energyReserve = ref({ items: [] })
const resourcesLoaded = ref(false)

/** Food/fuel are material ids 5 and 8 in player_items */
const EXCLUDED_MATERIAL_IDS = new Set([5, 8])

// 筛选状态
const selectedTypes = ref(['item', 'weapon', 'ammo', 'material'])

// 物资类型配置
const typeConfig = {
  item: { label: '道具', color: 'blue', icon: '📦' },
  weapon: { label: '武器', color: 'red', icon: '⚔️' },
  ammo: { label: '子弹', color: 'amber', icon: '🎯' },
  material: { label: '物资', color: 'emerald', icon: '🔧' }
}

// 物品名称映射
const itemNamesMap = {
  item: {
    1: '医疗资源',
    2: '手电筒',
    3: '手铐',
    4: '哨子',
    5: '防弹衣',
    6: '复合盾',
    7: '信号枪',
    8: '维修工具包',
    9: '交易凭证',
    10: '朗姆酒',
    11: '医疗材料',
    12: '渔网',
    13: '照明工具',
    14: '医用酒精',
    15: '点火工具',
    16: '书写工具',
    17: '导航工具',
    18: '面包',
    19: '仓库钥匙',
    20: '燃料仓库钥匙',
    21: '镇武库钥匙',
    22: '码头集购站钥匙',
    23: '反叛者基地钥匙',
    24: '方舟钥匙',
    25: '火把',
    26: '诅咒硬币',
    27: '祭坛石',
    28: '通灵笔记',
    29: '发光矿石碎片',
    30: '鱼鳞外套',
    31: '契约铁卷',
    32: '革命宣言',
    33: '古老龙骨图',
    34: '灰烬预言书',
    35: '人皮册子残页',
    36: '星象观测手稿',
    37: '尸油蜡烛',
    38: '深海鱼油蜡烛',
    39: '旧地图',
    40: '飞机部件·油箱',
    41: '飞机部件·起落架',
    42: '笔记本',
    43: '钢笔',
    44: '归墟罗盘',
    45: '龙骨刻刀',
    46: '灾厄之眼',
    47: '引魂烛台',
    48: '星轨轮盘',
    49: '烬火旗',
    50: '银币',
    51: '情绪抑制器',
    52: '共鸣石',
    53: '铁砧小队·记录员莉迪亚的私人笔记（残卷）',
    54: '飞机部件·副驾座',
    55: '避难所钥匙',
  },
  weapon: {
    1: '制式手枪',
    2: '猎枪',
    3: '警棍',
    4: '刺刀',
    5: '水手刀',
    6: '鱼叉/矛',
    7: '猎弓',
    8: '十字镐',
    9: '斧头',
    10: '电锯',
    11: '手术刀',
    12: '炸药',
    13: '电钻',
    14: '匕首',
    15: '铁镐'
  },
  ammo: {
    1: '手枪弹',
    2: '猎枪弹',
    3: '信号弹',
    4: '箭矢'
  },
  material: {
    1: '金属制品',
    2: '木材',
    3: '绳索',
    4: '木板',
    5: '食物',
    6: '沥青',
    7: '石料',
    8: '燃料',
    9: '帆布',
    10: '发动机',
    11: '螺旋桨',
    12: '发电机',
    13: '草木灰'
  }
}

// 物品单位映射
const itemUnitsMap = {
  item: {
    1: '个',
    2: '个',
    3: '个',
    4: '个',
    5: '件',
    6: '个',
    7: '把',
    8: '个',
    9: '个',
    10: '瓶',
    11: '份',
    12: '张',
    13: '套',
    14: '升',
    15: '个',
    16: '套',
    17: '个',
    18: '份',
    19: '把',
    20: '把',
    21: '把',
    22: '把',
    23: '把',
    24: '把',
    25: '把',
    26: '个',
    27: '枚',
    28: '本',
    29: '枚',
    30: '件',
    31: '卷',
    32: '份',
    33: '卷',
    34: '本',
    35: '页',
    36: '份',
    37: '支',
    38: '支',
    39: '张',
    40: '个',
    41: '个',
    42: '本',
    43: '支',
    44: '个',
    45: '把',
    46: '枚',
    47: '座',
    48: '个',
    49: '面',
    50: '枚',
    51: '个',
    52: '枚',
    53: '份',
    54: '个'
  },
  weapon: {
    1: '把',
    2: '把',
    3: '个',
    4: '把',
    5: '把',
    6: '个',
    7: '张',
    8: '把',
    9: '把',
    10: '把',
    11: '把',
    12: 'kg',
    13: '把',
    14: '把',
    15: '把'
  },
  ammo: {
    1: '枚',
    2: '枚',
    3: '枚',
    4: '枝'
  },
  material: {
    1: 'kg',
    2: 'kg',
    3: '米',
    4: 'kg',
    5: 'kg',
    6: 'kg',
    7: 'kg',
    8: 'kg',
    9: '米',
    10: '个',
    11: '个',
    12: '个',
    13: 'kg'
  }
}

// 物品备注映射
const itemRemarksMap = {
  item: {
    1: '恢复生命值',
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
    27: '地脉核心的封印碎片。持有即可地脉共鸣。快速行动：10单位资源互转，或所在地点防御+2。仪式材料可消耗1～3枚。原住民初始持有绑定个人仓库，不可被偷盗或被得知拥有，可交易或赠送。',
    28: '一本古旧的笔记，最后一页空白。据说拥有者可以借助它举行某种仪式。',
    29: '一块发出微弱脉动光的矿石碎片，可作为信物使用。',
    30: '一件覆盖细密鳞片的外套。每天一次可作为防弹衣效果。不可交易，不可被偷盗或任何方式被得知拥有。',
    31: '一卷用铁片串成的册子，记载着某种古老契约的完整条款。',
    32: '一份用铅笔写在旧报纸边缘的宣言，字迹潦草但充满力量。',
    33: '一卷发黄的羊皮纸，画着龙骨结构图，关键节点标注了奇怪的符文。',
    34: '一本被烧过但依然可读的皮面书，书页边缘焦黑，核心内容完整。',
    35: '装订怪异的册子残页，大部分已腐烂，记载着某种禁忌的内容。',
    36: '一叠详细记录星轨与星象的手稿，出自五十年前的一位灯塔看守之手。',
    37: '特制的蜡烛，燃烧时散发奇异的气味。据说是某些仪式的必需品。',
    38: '以深海鱼油制成的蜡烛，点燃后火焰呈幽蓝色。',
    39: '一张残旧的地图，标注着某个地点的大致位置。',
    40: '飞机用金属油箱，保存完好，可以安装使用。',
    41: '飞机起落架组件，结构完整，可以安装使用。',
    42: '一本可以书写记录的笔记本，初始5页。不可交易。',
    43: '一支可以正常书写的钢笔。不可交易。',
    44: '一枚刻满螺旋纹路的青铜盘，中心嵌着一颗永不下沉的黑色石子。',
    45: '一把由鲸骨打磨成的刻刀，刀柄镶嵌着一颗已石化的鱼眼珠。',
    46: '一枚黑色玻璃球，内部有不断旋转的暗红色雾气。',
    47: '一座三足青铜烛台，底座刻着扭曲的符文。',
    48: '一个用黑曜石磨成的圆盘，表面刻着黄道十二宫符号，中心有一处凹槽。',
    49: '一面被烧得只剩一半的旗帜，无论如何烧都不会彻底化为灰烬。',
    50: '一枚刻着衔尾蛇图案的旧银币，握在手中有刺骨的凉意。据说银币不属于活人。',
    51: '半头盔式银灰色合金装置，内衬黑色织物。侧面按钮与指示灯大多熄灭，一颗暗红色灯缓慢闪烁。内侧绣着「铁砧小队·标准配置·情绪抑制模块·型号MK-II」。装备后获得「情绪抑制」状态，持续到持有者主动解除或装备损坏。后续部分清醒仪式以此为源头。',
    52: '婴儿拳头大小深灰色卵石，握紧有节律震动，一端金属接口刻「白鸥小队·共鸣石·编号04」。消耗1次快速行动感知约200米内是否存在地脉异常点（只告知有/无）。每2天一次；用后眩晕耳鸣约半小时检定-1。夜晚闭眼使用可能看见不属于这个时代的残片，并获得持续1天的轻微「潮汐症」。',
    53: '铁砧小队记录员莉迪亚留下的残卷笔记。夹杂实验日志与个人感受：我们以为在观察这座岛，实际上这座岛也在观察我们。',
    54: '飞机副驾驶座组件，结构完整，可以安装使用。'
  },
  weapon: {
    1: '威胁值5',
    2: '威胁值6',
    3: '威胁值1',
    4: '威胁值2',
    5: '威胁值2',
    6: '威胁值3',
    7: '威胁值4',
    8: '威胁值1',
    9: '威胁值2',
    10: '威胁值4',
    11: '威胁值1',
    12: '威胁值极高',
    13: '钻孔工具',
    14: '一把锋利的匕首，便于隐蔽携带。威胁值2。',
    15: '结实的铁镐，可用于挖掘，紧急时也可作为武器。威胁值2。'
  },
  ammo: {
    1: '制式手枪子弹',
    2: '猎枪子弹',
    3: '信号枪子弹',
    4: '猎弓箭矢'
  },
  material: {
    1: '可用于制作工具',
    2: '可用于建造',
    3: '可提升探索成功程度',
    4: '建筑材料',
    5: '恢复饥饿',
    6: '建筑材料',
    7: '建筑材料',
    8: '提供能源',
    9: '制作帐篷',
    10: '机械动力',
    11: '船只推进',
    12: '发电设备',
    13: '1单位=1医疗资源'
  }
}

// 武器威胁值映射（与数据库 weapon.threat_level 保持一致）
const weaponThreatMap = {
  1: 5,
  2: 6,
  3: 1,
  4: 2,
  5: 2,
  6: 3,
  7: 4,
  8: 1,
  9: 2,
  10: 4,
  11: 1,
  12: 10,
  13: 1,
  14: 2,
  15: 2
}

// 弹药适用武器映射
const ammoWeaponMap = {
  1: '制式手枪',
  2: '猎枪',
  3: '信号枪',
  4: '猎弓'
}

// 物品图标映射
const itemIconMap = {
  item: {
    1: '🏥',
    2: '🔦',
    3: '⛓️',
    4: '📢',
    5: '🛡️',
    6: '🛡️',
    7: '🔫',
    8: '🔧',
    9: '💴',
    10: '🍾',
    11: '💊',
    12: '🕸️',
    13: '💡',
    14: '🧴',
    15: '🔥',
    16: '✏️',
    17: '🧭',
    18: '🍞',
    19: '🔑',
    20: '🔑',
    21: '🔑',
    22: '🔑',
    23: '🔑',
    24: '🔑',
    25: '🔥',
    26: '🪙',
    27: '✨',
    28: '📔',
    29: '💎',
    30: '🐟',
    31: '📜',
    32: '📃',
    33: '🦴',
    34: '📕',
    35: '📄',
    36: '🌟',
    37: '🕯️',
    38: '🕯️',
    39: '🗺️',
    40: '⛽',
    41: '⚙️',
    42: '📓',
    43: '🖊️',
    44: '🧭',
    45: '🔪',
    46: '👁️',
    47: '🕯️',
    48: '⭐',
    49: '🚩'
  },
  weapon: {
    1: '🔫',
    2: '🔫',
    3: '🏒',
    4: '🗡️',
    5: '🗡️',
    6: '🔱',
    7: '🏹',
    8: '⛏️',
    9: '🪓',
    10: '⚙️',
    11: '🔪',
    12: '💣',
    13: '🔧',
    14: '🗡️',
    15: '⛏️'
  },
  ammo: {
    1: '🎯',
    2: '🎯',
    3: '🎆',
    4: '📍'
  },
  material: {
    1: '🔩',
    2: '🪵',
    3: '🪢',
    4: '🪵',
    5: '🍞',
    6: '🛢️',
    7: '🪨',
    8: '⛽',
    9: '⛺',
    10: '⚙️',
    11: '⚓',
    12: '🔌',
    13: '🪨'
  }
}

// 加载物资数据
const loadMaterials = async () => {
  loading.value = true
  try {
    const [itemsResult, resourcesResult] = await Promise.all([
      playerAPI.getItems(playerId).catch(() => null),
      playerAPI.getResources(playerId).catch(() => null)
    ])
    if (Array.isArray(itemsResult)) {
      rawMaterials.value = itemsResult
    }
    resourcesLoaded.value = Boolean(resourcesResult?.success)
    if (resourcesResult?.success) {
      foodSupply.value = resourcesResult.foodSupply ?? {
        totalKg: resourcesResult.foodKg ?? 0,
        items: []
      }
      energyReserve.value = resourcesResult.energyReserve ?? { items: [] }
    } else {
      foodSupply.value = { totalKg: 0, items: [] }
      energyReserve.value = { items: [] }
    }
  } catch (error) {
    console.error('Failed to load materials:', error)
  } finally {
    loading.value = false
  }
}

// 转换物品数据
const transformItem = (type, item) => {
  const itemId = Number(item.id)
  return {
    id: itemId,
    name: (item.name && String(item.name).trim()) || itemNamesMap[type]?.[itemId] || '未知物品',
    unit: (item.unit && String(item.unit).trim()) || itemUnitsMap[type]?.[itemId] || '个',
    quantity: item.quantity,
    remark: (item.remark && String(item.remark).trim()) || itemRemarksMap[type]?.[itemId] || '',
    icon: itemIconMap[type]?.[itemId] || '📦',
    imageUrl: getMaterialImageUrlOrDefault(type, itemId),
    threat_level: type === 'weapon' ? (item.threatLevel ?? weaponThreatMap[itemId]) : undefined,
    weapon_name: type === 'ammo' ? ammoWeaponMap[itemId] : undefined
  }
}

// 计算属性：获取当前玩家的各类物资
const currentItems = computed(() => {
  return rawMaterials.value.filter(i => i.type === 'item').map(i => transformItem('item', i))
})

const currentWeapons = computed(() => {
  return rawMaterials.value.filter(i => i.type === 'weapon').map(i => transformItem('weapon', i))
})

const currentAmmo = computed(() => {
  return rawMaterials.value.filter(i => i.type === 'ammo').map(i => transformItem('ammo', i))
})

const currentMaterials = computed(() => {
  return rawMaterials.value
    .filter(i => i.type === 'material' && !EXCLUDED_MATERIAL_IDS.has(Number(i.id)))
    .map(i => transformItem('material', i))
})

// 计算属性：根据筛选条件显示的物资
const filteredData = computed(() => {
  const result = {}
  if (selectedTypes.value.includes('item')) {
    result.item = currentItems.value
  }
  if (selectedTypes.value.includes('weapon')) {
    result.weapon = currentWeapons.value
  }
  if (selectedTypes.value.includes('ammo')) {
    result.ammo = currentAmmo.value
  }
  if (selectedTypes.value.includes('material')) {
    result.material = currentMaterials.value
  }
  return result
})

// 计算属性：是否有任何物资
const hasAnyMaterials = computed(() => {
  return resourcesLoaded.value ||
         currentItems.value.length > 0 ||
         currentWeapons.value.length > 0 ||
         currentAmmo.value.length > 0 ||
         currentMaterials.value.length > 0
})

const hasFoodOrEnergyStock = computed(() => {
  const foodItems = (foodSupply.value.items || []).some(i => Number(i.quantity) > 0)
  const energyItems = (energyReserve.value.items || []).some(i => Number(i.quantity) > 0)
  return foodItems || energyItems || (foodSupply.value.totalKg ?? 0) > 0
})

// 计算属性：当前筛选条件下是否有物资
const hasFilteredMaterials = computed(() => {
  return hasFoodOrEnergyStock.value ||
         Object.values(filteredData.value).some(arr => arr.length > 0)
})

const toggleType = (type) => {
  const index = selectedTypes.value.indexOf(type)
  if (index > -1) {
    // 至少保留一个选中
    if (selectedTypes.value.length > 1) {
      selectedTypes.value.splice(index, 1)
    }
  } else {
    selectedTypes.value.push(type)
  }
}

// 全选/取消全选
const toggleAll = () => {
  if (selectedTypes.value.length === 4) {
    selectedTypes.value = ['item']
  } else {
    selectedTypes.value = ['item', 'weapon', 'ammo', 'material']
  }
}

function typeCount(type) {
  if (type === 'item') return currentItems.value.length
  if (type === 'weapon') return currentWeapons.value.length
  if (type === 'ammo') return currentAmmo.value.length
  if (type === 'material') return currentMaterials.value.length
  return 0
}

const typeChipOn = {
  item: 'bg-sky-500/25 text-sky-100 border-sky-400/50',
  weapon: 'bg-rose-500/25 text-rose-100 border-rose-400/50',
  ammo: 'bg-amber-500/25 text-amber-100 border-amber-400/50',
  material: 'bg-emerald-500/25 text-emerald-100 border-emerald-400/50',
}

// 获取威胁值颜色
const getThreatColor = (level) => {
  if (level >= 8) return 'text-red-400 bg-red-500/20'
  if (level >= 6) return 'text-amber-400 bg-amber-500/20'
  if (level >= 4) return 'text-yellow-400 bg-yellow-500/20'
  return 'text-emerald-400 bg-emerald-500/20'
}

// 获取物资背景色
const getItemBgColor = (type) => {
  const colors = {
    item: 'from-blue-400/20 to-blue-500/20',
    weapon: 'from-red-400/20 to-red-500/20',
    ammo: 'from-amber-400/20 to-amber-500/20',
    material: 'from-emerald-400/20 to-emerald-500/20'
  }
  return colors[type] || colors.item
}

// 页面可见性改变时刷新
const handleVisibilityChange = () => {
  if (!document.hidden) {
    loadMaterials()
  }
}

onMounted(() => {
  loadMaterials()
  document.addEventListener('visibilitychange', handleVisibilityChange)
})

onUnmounted(() => {
  document.removeEventListener('visibilitychange', handleVisibilityChange)
})
</script>

<template>
  <div class="max-w-7xl">
    <div class="mb-5 flex flex-wrap items-end justify-between gap-3">
      <div>
        <h1 class="text-white mb-1 tracking-tight text-2xl">背包</h1>
        <p class="text-gray-500 text-sm">物资与装备管理</p>
      </div>
      <div class="flex flex-wrap items-center gap-1.5">
        <button
          type="button"
          class="px-2.5 py-1 rounded-lg text-xs font-medium border"
          :class="selectedTypes.length === 4
            ? 'bg-white/15 text-white border-white/25'
            : 'bg-transparent text-gray-400 border-white/10 hover:text-white hover:border-white/20'"
          @click="toggleAll"
        >
          全部
        </button>
        <button
          v-for="(config, type) in typeConfig"
          :key="type"
          type="button"
          class="px-2.5 py-1 rounded-lg text-xs font-medium border"
          :class="selectedTypes.includes(type)
            ? typeChipOn[type]
            : 'bg-transparent text-gray-400 border-white/10 hover:text-gray-200 hover:border-white/20'"
          @click="toggleType(type)"
        >
          {{ config.label }}
          <span v-if="typeCount(type)" class="opacity-70 ml-0.5">{{ typeCount(type) }}</span>
        </button>
      </div>
    </div>

    <!-- 食物 / 燃料明细 -->
    <div
      class="bg-gradient-to-br from-[#1a2332] to-[#0f1419] border border-white/10 rounded-2xl p-5 mb-6"
    >
      <div class="flex items-center gap-3 mb-2">
        <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-amber-400/20 to-yellow-500/20 flex items-center justify-center text-xl">
          🍞
        </div>
        <div>
          <h2 class="text-white text-lg font-medium">食物与燃料</h2>
          <p class="text-gray-500 text-xs">按类型统计</p>
        </div>
      </div>
      <p v-if="!loading && !resourcesLoaded" class="text-amber-500/90 text-sm mb-3">
        无法加载食物与燃料数据。请确认 Spring Boot 后端已启动，且 material 表包含 id 5（食物）与 id 8（燃料）。
      </p>
      <ShelterSupplyCards
        v-else
        embedded
        food-title="个人食物"
        energy-title="个人燃料"
        :food="foodSupply"
        :energy="energyReserve"
      />
    </div>

    <div v-if="hasFilteredMaterials" class="space-y-8">
      <div v-if="selectedTypes.includes('item') && filteredData.item?.length > 0">
        <div class="flex items-center gap-3 mb-4">
          <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-400/20 to-blue-500/20 flex items-center justify-center p-1.5">
            <img :src="getTypeTabImage('item')" alt="" class="w-7 h-7 object-contain" />
          </div>
          <div>
            <h2 class="text-white text-lg font-medium">道具</h2>
            <p class="text-gray-500 text-xs">道具与装备</p>
          </div>
          <div class="ml-auto text-sm text-gray-400">
            共 {{ filteredData.item.length }} 件
          </div>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          <div
            v-for="item in filteredData.item"
            :key="item.id"
            class="relative bg-gradient-to-br from-[#1a2332] to-[#0f1419] border border-white/10 rounded-2xl p-5 overflow-hidden hover:border-white/20 transition-all group"
          >
            <div class="absolute top-0 right-0 w-32 h-32 bg-blue-500/5 rounded-full blur-2xl group-hover:bg-blue-500/10 transition-all" />
            
            <div class="relative flex items-start gap-4">
              <div
                class="w-14 h-14 rounded-xl bg-gradient-to-br from-blue-400/20 to-blue-500/20 flex items-center justify-center text-2xl flex-shrink-0 overflow-hidden p-1"
              >
                <img
                  :src="item.imageUrl"
                  :alt="item.name"
                  class="w-full h-full object-contain"
                />
              </div>
              
              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between mb-1">
                  <h3 class="text-white font-medium truncate">{{ item.name }}</h3>
                  <span class="text-xs text-gray-400 bg-white/5 px-2 py-1 rounded-full">{{ item.unit }}</span>
                </div>
                
                <div class="flex items-center gap-2 mb-3">
                  <span class="text-xs text-gray-500">数量</span>
                  <span class="text-lg font-semibold text-blue-400">{{ item.quantity }}</span>
                </div>
                <p v-if="item.remark" class="text-gray-400 text-xs leading-relaxed line-clamp-4">{{ item.remark }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 武器区域 -->
      <div v-if="selectedTypes.includes('weapon') && filteredData.weapon?.length > 0">
        <div class="flex items-center gap-3 mb-4">
          <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-red-400/20 to-red-500/20 flex items-center justify-center p-1.5">
            <img :src="getTypeTabImage('weapon')" alt="" class="w-7 h-7 object-contain" />
          </div>
          <div>
            <h2 class="text-white text-lg font-medium">武器</h2>
            <p class="text-gray-500 text-xs">武器与弹药</p>
          </div>
          <div class="ml-auto text-sm text-gray-400">
            共 {{ filteredData.weapon.length }} 件
          </div>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          <div
            v-for="weapon in filteredData.weapon"
            :key="weapon.id"
            class="relative bg-gradient-to-br from-[#1a2332] to-[#0f1419] border border-white/10 rounded-2xl p-5 overflow-hidden hover:border-white/20 transition-all group"
          >
            <div class="absolute top-0 right-0 w-32 h-32 bg-red-500/5 rounded-full blur-2xl group-hover:bg-red-500/10 transition-all" />
            
            <div class="relative flex items-start gap-4">
              <div
                class="w-14 h-14 rounded-xl bg-gradient-to-br from-red-400/20 to-red-500/20 flex items-center justify-center text-2xl flex-shrink-0 overflow-hidden p-1"
              >
                <img
                  :src="weapon.imageUrl"
                  :alt="weapon.name"
                  class="w-full h-full object-contain"
                />
              </div>
              
              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between mb-1">
                  <h3 class="text-white font-medium truncate">{{ weapon.name }}</h3>
                  <span class="text-xs text-gray-400 bg-white/5 px-2 py-1 rounded-full">{{ weapon.unit }}</span>
                </div>
                
                <div class="flex items-center justify-between mb-3">
                  <div class="flex items-center gap-2">
                    <span class="text-xs text-gray-500">数量</span>
                    <span class="text-lg font-semibold text-red-400">{{ weapon.quantity }}</span>
                  </div>
                  <span :class="['text-xs px-2 py-1 rounded-full', getThreatColor(weapon.threat_level)]">
                    威胁 {{ weapon.threat_level }}
                  </span>
                </div>
                <p v-if="weapon.remark" class="text-gray-400 text-xs leading-relaxed line-clamp-4">{{ weapon.remark }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 子弹区域 -->
      <div v-if="selectedTypes.includes('ammo') && filteredData.ammo?.length > 0">
        <div class="flex items-center gap-3 mb-4">
          <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-amber-400/20 to-amber-500/20 flex items-center justify-center p-1.5">
            <img :src="getTypeTabImage('ammo')" alt="" class="w-7 h-7 object-contain" />
          </div>
          <div>
            <h2 class="text-white text-lg font-medium">子弹</h2>
            <p class="text-gray-500 text-xs">弹药</p>
          </div>
          <div class="ml-auto text-sm text-gray-400">
            共 {{ filteredData.ammo.length }} 种
          </div>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          <div
            v-for="ammo in filteredData.ammo"
            :key="ammo.id"
            class="relative bg-gradient-to-br from-[#1a2332] to-[#0f1419] border border-white/10 rounded-2xl p-5 overflow-hidden hover:border-white/20 transition-all group"
          >
            <div class="absolute top-0 right-0 w-32 h-32 bg-amber-500/5 rounded-full blur-2xl group-hover:bg-amber-500/10 transition-all" />
            
            <div class="relative flex items-start gap-4">
              <div
                class="w-14 h-14 rounded-xl bg-gradient-to-br from-amber-400/20 to-amber-500/20 flex items-center justify-center text-2xl flex-shrink-0 overflow-hidden p-1"
              >
                <img
                  :src="ammo.imageUrl"
                  :alt="ammo.name"
                  class="w-full h-full object-contain"
                />
              </div>
              
              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between mb-1">
                  <h3 class="text-white font-medium truncate">{{ ammo.name }}</h3>
                  <span class="text-xs text-gray-400 bg-white/5 px-2 py-1 rounded-full">{{ ammo.unit }}</span>
                </div>
                
                <div class="flex items-center gap-2 mb-2">
                  <span class="text-xs text-gray-500">数量</span>
                  <span class="text-lg font-semibold text-amber-400">{{ ammo.quantity }}</span>
                </div>
                <div class="flex items-center gap-2 mb-3">
                  <span class="text-xs text-gray-500">适用</span>
                  <span class="text-xs text-amber-400 bg-amber-500/10 px-2 py-1 rounded">{{ ammo.weapon_name }}</span>
                </div>
                <p v-if="ammo.remark" class="text-gray-400 text-xs leading-relaxed line-clamp-4">{{ ammo.remark }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 其他物资区域 -->
      <div v-if="selectedTypes.includes('material') && filteredData.material?.length > 0">
        <div class="flex items-center gap-3 mb-4">
          <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-emerald-400/20 to-emerald-500/20 flex items-center justify-center p-1.5">
            <img :src="getTypeTabImage('material')" alt="" class="w-7 h-7 object-contain" />
          </div>
          <div>
            <h2 class="text-white text-lg font-medium">其他物资</h2>
            <p class="text-gray-500 text-xs">Other Materials</p>
          </div>
          <div class="ml-auto text-sm text-gray-400">
            共 {{ filteredData.material.length }} 种
          </div>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 mb-4">
          <div
            v-for="material in filteredData.material"
            :key="material.id"
            class="relative bg-gradient-to-br from-[#1a2332] to-[#0f1419] border border-white/10 rounded-2xl p-5 overflow-hidden hover:border-white/20 transition-all group"
          >
            <div class="absolute top-0 right-0 w-32 h-32 bg-emerald-500/5 rounded-full blur-2xl group-hover:bg-emerald-500/10 transition-all" />
            
            <div class="relative flex items-start gap-4">
              <div
                class="w-14 h-14 rounded-xl bg-gradient-to-br from-emerald-400/20 to-emerald-500/20 flex items-center justify-center text-2xl flex-shrink-0 overflow-hidden p-1"
              >
                <img
                  :src="material.imageUrl"
                  :alt="material.name"
                  class="w-full h-full object-contain"
                />
              </div>
              
              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between mb-1">
                  <h3 class="text-white font-medium truncate">{{ material.name }}</h3>
                  <span class="text-xs text-gray-400 bg-white/5 px-2 py-1 rounded-full">{{ material.unit }}</span>
                </div>
                
                <div class="flex items-center gap-2 mb-3">
                  <span class="text-xs text-gray-500">数量</span>
                  <span class="text-lg font-semibold text-emerald-400">{{ material.quantity }}</span>
                </div>
                <p v-if="material.remark" class="text-gray-400 text-xs leading-relaxed line-clamp-4">{{ material.remark }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 空状态 -->
    <div v-else-if="!hasAnyMaterials" class="flex flex-col items-center justify-center py-20">
      <div class="w-24 h-24 rounded-full bg-white/5 flex items-center justify-center mb-4">
        <span class="text-4xl">📦</span>
      </div>
      <h3 class="text-white text-lg mb-2">暂无物资</h3>
      <p class="text-gray-500 text-sm">您当前没有任何物资</p>
    </div>

    <!-- 筛选后无数据 -->
    <div v-else class="flex flex-col items-center justify-center py-20">
      <div class="w-24 h-24 rounded-full bg-white/5 flex items-center justify-center mb-4">
        <span class="text-4xl">🔍</span>
      </div>
      <h3 class="text-white text-lg mb-2">未找到物资</h3>
      <p class="text-gray-500 text-sm">当前筛选条件下没有物资</p>
    </div>
  </div>
</template>
