/**
 * 项目统一数据文件（避免 src/data 下零散多个 .js）。
 *
 * 包含：
 * - 物资管理页：后端 item / weapon / ammo / material 的 id 与本地素材对应关系
 * - 统治者避难所：图鉴、物资展示映射、建造日志（演示数据）
 *
 * 说明：
 * - 有对应 PNG 的 id 会映射到素材；无映射时 `getMaterialImageUrl` 返回 null。
 * - `getMaterialImageUrlOrDefault` 在无映射时返回统一占位图（医疗包），供界面始终可显示图片。
 */

// -----------------------------
// 素材（assets）
// -----------------------------
import imgMedicalKit from '@/assets/医疗包.png?url'
import imgFlashlight from '@/assets/手电筒.png?url'
import imgHandcuffs from '@/assets/手铐.png?url'
import imgWhistle from '@/assets/哨子.png?url'
import imgBodyArmor from '@/assets/防弹衣.png?url'
import imgCompositeShield from '@/assets/复合盾.png?url'
import imgFlareGun from '@/assets/信号枪.png?url'
import imgRepairKit from '@/assets/维修工具包.png?url'
import imgContract from '@/assets/协议书.png?url'
import imgRum from '@/assets/朗姆酒.png?url'
import imgHerbs from '@/assets/草药.png?url'
import imgFishingNet from '@/assets/渔网.png?url'
import imgCandle from '@/assets/蜡烛.png?url'
import imgAlcohol from '@/assets/医用酒精.png?url'
import imgMatches from '@/assets/火柴.png?url'
import imgPencil from '@/assets/铅笔.png?url'
import imgSeaChart from '@/assets/破损海图.png?url'
import imgBento from '@/assets/面包.png?url'
import imgFood from '@/assets/Food.png?url'
import imgFuel from '@/assets/Fuel.png?url'
import imgServicePistol from '@/assets/制式手枪.png?url'
import imgHuntingShotgun from '@/assets/猎枪.png?url'
import imgBaton from '@/assets/警棍.png?url'
import imgBayonet from '@/assets/刺刀.png?url'
import imgHarpoon from '@/assets/鱼叉_矛.png?url'
import imgHuntingBow from '@/assets/猎弓.png?url'
import imgPickaxe from '@/assets/十字镐.png?url'
import imgAxe from '@/assets/斧头.png?url'
import imgRifle from '@/assets/步枪.png?url'
import imgWood from '@/assets/木材.png?url'
import imgStone from '@/assets/石料.png?url'
import imgPlank from '@/assets/木板.png?url'
import imgRope from '@/assets/绳索.png?url'
import imgWarehouseKey from '@/assets/仓库钥匙.png?url'
import imgFuelDepotKey from '@/assets/燃料仓库钥匙.png?url'
import imgArmoryKey from '@/assets/镇武库钥匙.png?url'
import imgDockMarketKey from '@/assets/码头集购站钥匙.png?url'
import imgRebelBaseKey from '@/assets/反叛者基地钥匙.png?url'
import imgArkKey from '@/assets/方舟钥匙.png?url'
import imgPrisonKey from '@/assets/监狱钥匙.png?url'
import imgSailorKnife from '@/assets/水手刀.png?url'
import imgElectricDrill from '@/assets/电钻.png?url'
import imgMetalProducts from '@/assets/金属制品.png?url'
import imgAsphalt from '@/assets/沥青.png?url'
import imgCanvas from '@/assets/帆布.png?url'
import imgEngine from '@/assets/发动机.png?url'
import imgPropeller from '@/assets/螺旋桨.png?url'
import imgGenerator from '@/assets/发电机.png?url'
import imgChainsaw from '@/assets/电锯.png?url'
import imgScalpel from '@/assets/手术刀.png?url'
import imgExplosives from '@/assets/炸药.png?url'
import imgTorch from '@/assets/火把.png?url'
import imgCursedCoin from '@/assets/诅咒硬币.png?url'
import imgPlantAsh from '@/assets/草木灰.png?url'
import { normalizeShelterTransportAlias } from '@/utils/transportForm.js'

// -----------------------------
// 物资管理页：图片映射
// -----------------------------
const ITEM_IMAGES = {
  1: imgMedicalKit,
  2: imgFlashlight,
  3: imgHandcuffs,
  4: imgWhistle,
  5: imgBodyArmor,
  6: imgCompositeShield,
  7: imgFlareGun,
  8: imgRepairKit,
  9: imgContract,
  10: imgRum,
  11: imgHerbs,
  12: imgFishingNet,
  13: imgCandle,
  14: imgAlcohol,
  15: imgMatches,
  16: imgPencil,
  17: imgSeaChart,
  18: imgBento,
  19: imgWarehouseKey,
  20: imgFuelDepotKey,
  21: imgArmoryKey,
  22: imgDockMarketKey,
  23: imgRebelBaseKey,
  24: imgArkKey,
  25: imgTorch,
  26: imgCursedCoin,
  55: imgWarehouseKey,
}

const WEAPON_IMAGES = {
  1: imgServicePistol,
  2: imgHuntingShotgun,
  3: imgBaton,
  4: imgBayonet,
  5: imgSailorKnife,
  6: imgHarpoon,
  7: imgHuntingBow,
  8: imgPickaxe,
  9: imgAxe,
  10: imgChainsaw,
  11: imgScalpel,
  12: imgExplosives,
  13: imgElectricDrill,
}

const AMMO_IMAGES = {
  // 弹药暂无独立素材，先用对应武器素材占位
  1: imgServicePistol,
  2: imgHuntingShotgun,
  3: imgFlareGun,
  4: imgHuntingBow,
}

const MATERIAL_IMAGES = {
  1: imgMetalProducts,
  2: imgWood,
  3: imgRope,
  4: imgPlank,
  6: imgAsphalt,
  7: imgStone,
  9: imgCanvas,
  10: imgEngine,
  11: imgPropeller,
  12: imgGenerator,
  13: imgPlantAsh,
  5: imgFood,
  8: imgFuel,
}

const MATERIAL_MAPS = {
  item: ITEM_IMAGES,
  weapon: WEAPON_IMAGES,
  ammo: AMMO_IMAGES,
  material: MATERIAL_IMAGES,
}

// 与数据库 item / weapon / ammo / material 表同步（snowisland_5_15.sql）
export const GAME_ITEM_NAMES = {
  item: {
    1: '医疗资源',
    2: '手电筒',
    3: '手铐',
    4: '哨子',
    5: '防弹衣',
    6: '复合盾',
    7: '信号枪',
    8: '维修工具包',
    9: '协议书',
    10: '朗姆酒',
    11: '草药',
    12: '渔网',
    13: '蜡烛',
    14: '医用酒精',
    15: '火柴',
    16: '铅笔',
    17: '破损海图',
    18: '面包',
    19: '矿场仓库钥匙',
    20: '燃料仓库钥匙',
    21: '镇武库钥匙',
    22: '码头集换站钥匙',
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
    15: '铁镐',
  },
  ammo: {
    1: '手枪弹',
    2: '猎枪弹',
    3: '信号弹',
    4: '箭矢',
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
    13: '草木灰',
  },
}

/** 前端交易侧过滤用；不可交易判定以数据库 item.tradable 为准 */
export const NON_TRADABLE_ITEM_IDS = new Set([30, 42, 43])

/**
 * 描述文本中的「威胁值N」按数据库 threat_level 动态渲染，避免改威胁值后描述数字过期。
 * 无数字的写法（如「威胁值极高」）不受影响。
 * @param {string} remark
 * @param {number|string|null} threatLevel
 */
export function syncThreatInRemark(remark, threatLevel) {
  const text = remark || ''
  if (!text || threatLevel == null) return text
  const t = Number(threatLevel)
  if (!Number.isFinite(t)) return text
  return text.replace(/威胁值\s*\d+/g, `威胁值${t}`)
}

/**
 * @param {'item'|'weapon'|'ammo'|'material'|string} itemType
 * @param {number|string} itemId
 */
export function getItemDisplayName(itemType, itemId) {
  if (itemType == null || itemId === '' || itemId === undefined) return '未知物品'
  const t = String(itemType).toLowerCase()
  const numId = typeof itemId === 'number' && Number.isFinite(itemId) ? itemId : parseInt(String(itemId), 10)
  if (Number.isNaN(numId)) return '未知物品'
  return GAME_ITEM_NAMES[t]?.[numId] ?? '未知物品'
}

export function formatTransportItemLine(item) {
  const name = getItemDisplayName(item.itemType, item.itemId)
  return `${name} × ${item.quantity}（${item.weight}千克/单位）`
}

/** 将行动结果中的 material-3 等形式替换为中文名称 */
export function formatActionResultText(text) {
  if (!text) return text
  return String(text).replace(
    /\b(item|weapon|ammo|material)-(\d+)\b/g,
    (_, type, id) => getItemDisplayName(type, id),
  )
}

const WAREHOUSE_LABELS = {
  general: '通用仓库',
  fuel: '燃料仓库',
  armory: '镇武库',
  dock: '码头集换站',
  rebel: '反叛者基地',
  ark: '方舟仓库',
  shelter: '避难所仓库',
}

const TRANSPORT_MODE_LABELS_ACTION = {
  warehouse_to_warehouse: '仓库→仓库（上限500千克）',
  warehouse_to_player: '仓库→个人（上限300千克）',
  player_to_warehouse: '个人→仓库（上限300千克）',
  warehouse_to_shelter: '仓库→避难所（上限500千克）',
  shelter_to_warehouse: '避难所→仓库（上限500千克，仅统治者）',
  shelter_to_player: '避难所→个人（上限300千克，仅统治者）',
  player_to_shelter: '个人→避难所（上限300千克）',
}

const TRANSPORT_MODE_LABELS_FREE = {
  warehouse_to_warehouse: '仓库→仓库（免费档上限100千克，海岛50千克）',
  warehouse_to_player: '仓库→个人（免费档上限50千克）',
  player_to_warehouse: '个人→仓库（免费档上限50千克）',
  warehouse_to_shelter: '仓库→避难所（免费档上限50千克）',
  shelter_to_warehouse: '避难所→仓库（免费档上限50千克，仅统治者）',
  shelter_to_player: '避难所→个人（免费档上限50千克，仅统治者）',
  player_to_shelter: '个人→避难所（免费档上限50千克）',
}

function transportModeDisplayLabel(mode, free) {
  const table = free ? TRANSPORT_MODE_LABELS_FREE : TRANSPORT_MODE_LABELS_ACTION
  return table[mode] || mode
}

const STRUCTURED_NOTE_LINE = /^\[(mode|source|dest|item|target|player_deducted|tier):/

/** @returns {{ mode: string, source: string, dest: string, tier: string, items: Array<{ itemType: string, itemId: string, quantity: string, weight: string }> } | null} */
export function parseTransportNotes(notes) {
  if (!notes) return null
  const info = { mode: '', source: '', dest: '', tier: '', targetPlayerId: '', items: [] }
  let hasStructured = false
  for (const line of String(notes).split('\n')) {
    const trimmed = line.trim()
    if (trimmed.startsWith('[target:')) {
      hasStructured = true
      const closeIdx = trimmed.indexOf(']')
      if (closeIdx > 8) info.targetPlayerId = trimmed.substring(8, closeIdx)
    } else if (trimmed.startsWith('[tier:')) {
      hasStructured = true
      const closeIdx = trimmed.indexOf(']')
      if (closeIdx > 6) info.tier = trimmed.substring(6, closeIdx)
    } else if (trimmed.startsWith('[mode:')) {
      hasStructured = true
      const closeIdx = trimmed.indexOf(']')
      if (closeIdx > 6) info.mode = trimmed.substring(6, closeIdx)
    } else if (trimmed.startsWith('[source:')) {
      hasStructured = true
      const closeIdx = trimmed.indexOf(']')
      if (closeIdx > 8) info.source = trimmed.substring(8, closeIdx)
    } else if (trimmed.startsWith('[dest:')) {
      hasStructured = true
      const closeIdx = trimmed.indexOf(']')
      if (closeIdx > 6) info.dest = trimmed.substring(6, closeIdx)
    } else if (trimmed.startsWith('[item:')) {
      hasStructured = true
      const closeIdx = trimmed.indexOf(']')
      if (closeIdx > 6) {
        const parts = trimmed.substring(6, closeIdx).split('|')
        if (parts.length >= 4) {
          info.items.push({
            itemType: parts[0],
            itemId: parts[1],
            quantity: parts[2],
            weight: parts[3],
          })
        }
      }
    }
  }
  return hasStructured ? normalizeShelterTransportAlias(info) : null
}

function warehouseLabel(key, warehouseNameByKey = {}) {
  if (!key) return ''
  if (key === 'shelter') return '避难所仓库'
  return warehouseNameByKey[key] || WAREHOUSE_LABELS[key] || key
}

/** 将搬运结构化备注格式化为中文（供 DM 查看玩家提交） */
export function formatTransportNotesForDisplay(notes, warehouseNameByKey = {}, options = {}) {
  const info = parseTransportNotes(notes)
  if (!info) return ''
  const lines = []
  if (info.mode) {
    const free = options.free === true
      || options.actionSlot === 0
      || String(info.tier || '').toLowerCase() === 'free'
    lines.push(`模式：${transportModeDisplayLabel(info.mode, free)}`)
  }
  if (info.source) lines.push(`源仓库：${warehouseLabel(info.source, warehouseNameByKey)}`)
  if (info.dest) lines.push(`目标仓库：${warehouseLabel(info.dest, warehouseNameByKey)}`)
  if (info.targetPlayerId) lines.push(`目标玩家ID：${info.targetPlayerId}`)
  for (const item of info.items) {
    lines.push(`物资：${formatTransportItemLine(item)}`)
  }
  return lines.join('\n')
}

/** 玩家自由填写的备注（排除搬运结构化行） */
export function extractFreeformPlayerNotes(notes) {
  if (!notes) return ''
  return String(notes)
    .split('\n')
    .map((l) => l.trim())
    .filter((l) => l && !STRUCTURED_NOTE_LINE.test(l))
    .join('\n')
    .trim()
}

/** DM 弹窗顶部：玩家备注（搬运仅显示中文摘要，隐藏结构化行） */
export function getPlayerNotesDisplay(action, warehouseNameByKey = {}) {
  if (!action?.notes?.trim()) return '（无备注）'
  if (action.actionType === 'transport') {
    const plan = formatTransportNotesForDisplay(action.notes, warehouseNameByKey, {
      actionSlot: action.actionSlot,
    })
    const free = extractFreeformPlayerNotes(action.notes)
    if (plan) return free ? `${plan}\n\n${free}` : plan
    return free || '（无备注）'
  }
  return action.notes.trim()
}

/** 数量输入：非负整数，上限 optional */
export function sanitizeNonNegativeInt(value, max = Infinity) {
  let n = parseInt(String(value), 10)
  if (Number.isNaN(n) || n < 0) n = 0
  n = Math.floor(n)
  if (n > max) n = max
  return n
}

/** 数量输入：正整数（至少 1），上限 optional；无效时返回 1 */
export function sanitizePositiveInt(value, max = Infinity) {
  let n = parseInt(String(value), 10)
  if (Number.isNaN(n) || n < 1) n = 1
  n = Math.floor(n)
  if (n > max) n = max
  return n
}

const TRANSPORT_PENDING_MARKER = '\n\n【搬运待发布】\n'

export function stripTransportPendingFromResult(result) {
  if (!result) return ''
  const text = String(result)
  const idx = text.indexOf(TRANSPORT_PENDING_MARKER)
  if (idx >= 0) return text.slice(0, idx).trim()
  return text.trim()
}

function stripPendingPlaceholders(text) {
  if (!text) return ''
  return String(text)
    .replace(/^等待DM反馈[^\n]*\n?/gm, '')
    .replace(/^已提交，等待主持人确认。[^\n]*\n?/gm, '')
    .trim()
}

/** DM 反馈编辑框初始内容：已保存的 DM 文案，或系统/auto 结算文本 */
export function getDmFeedbackDraft(action) {
  if (isActionFailed(action)) {
    const saved = extractDmFeedback(action?.result) || action?.dmFeedback
    return saved ? formatActionResultText(saved) : generateActionFailureFeedback(action)
  }
  const saved = extractDmFeedback(action?.result) || action?.dmFeedback
  if (saved) return formatActionResultText(saved)
  let system = stripDmFeedbackFromResult(action?.result)
  system = stripTransportPendingFromResult(system)
  system = stripPendingPlaceholders(system)
  return formatActionResultText(system) || ''
}

/** 玩家端展示：优先 DM 反馈正文，否则系统结果 */
export function formatPlayerActionResult(result) {
  if (!result) return ''
  if (String(result).includes('[mode:')) {
    const zh = formatTransportNotesForDisplay(result)
    if (zh) return zh
  }
  const dm = extractDmFeedback(result)
  if (dm) return formatActionResultText(dm)
  return formatActionResultText(stripDmFeedbackFromResult(result))
}

const DM_FEEDBACK_MARKER = '【DM反馈】'
export const ACTION_FAILED_MARKER = '【行动失败】'

export function isActionFailed(actionOrResult) {
  const result = typeof actionOrResult === 'string' ? actionOrResult : actionOrResult?.result
  if (!result) return Boolean(actionOrResult?.actionFailed)
  return String(result).includes(ACTION_FAILED_MARKER) || Boolean(actionOrResult?.actionFailed)
}

/** 按行动类型生成失败反馈文案（不含【行动失败】标记，标记由后端写入） */
export function generateActionFailureFeedback(action) {
  if (!action) return '你的行动未能成功，请等待主持人说明具体情况。'
  const target = action.targetName || ''
  const lines = []
  switch (action.actionType) {
    case 'go_location':
      lines.push(
        target
          ? `你前往「${target}」的行动未能成功，未能按预期完成探索或互动。`
          : '你的前往地点行动未能成功。',
      )
      break
    case 'investigate_player':
      lines.push(
        target
          ? `你对「${target}」的调查未能成功，未能掌握其当日行动情报。`
          : '你的调查玩家行动未能成功。',
      )
      break
    case 'produce':
      lines.push('你的生产行动未能成功，今日未获得预期产出。')
      break
    case 'use_trait':
      lines.push('你的特性使用未能生效（条件不满足、被打断或遭否决）。')
      break
    case 'use_skill':
      lines.push('你的职业技能未能生效（条件不满足、被打断或遭否决）。')
      break
    case 'transport':
      lines.push('你的搬运行动未能成功，物资未按申请完成转移。')
      if (action.notes?.includes('[player_deducted:1]')) {
        lines.push('已从你背包预扣的物资将退还。')
      }
      break
    case 'hide':
      lines.push('你的隐藏行动未能成功，你未能进入隐藏状态。')
      break
    default:
      lines.push(`你的行动（${actionShortLabel(action)}）未能成功。`)
  }
  return lines.join('\n')
}

/** Extract DM-authored feedback from stored action result. */
export function extractDmFeedback(result) {
  if (!result) return ''
  const text = String(result)
  const marker = text.indexOf(DM_FEEDBACK_MARKER)
  if (marker < 0) return ''
  const after = text.indexOf('\n', marker)
  if (after < 0) return ''
  return text.slice(after + 1).trim()
}

export function stripDmFeedbackFromResult(result) {
  if (!result) return ''
  const text = String(result)
  const idx = text.indexOf(`\n\n${DM_FEEDBACK_MARKER}`)
  if (idx >= 0) return text.slice(0, idx).trim()
  const idx2 = text.indexOf(DM_FEEDBACK_MARKER)
  if (idx2 >= 0) return text.slice(0, idx2).trim()
  return text.trim()
}

const ACTION_TYPE_LABELS = {
  go_location: '前往地点',
  investigate_player: '调查玩家',
  produce: '生产',
  use_trait: '使用特性',
  use_skill: '使用职业技能',
  transport: '搬运',
  hide: '隐藏',
  other: '其他',
}

export function actionTypeLabel(action) {
  if (!action) return '—'
  return action.actionTypeLabel || ACTION_TYPE_LABELS[action.actionType] || action.actionType || '—'
}

export function actionShortLabel(action) {
  if (!action) return '未提交'
  let label = actionTypeLabel(action)
  if (action.targetName) label += ` → ${action.targetName}`
  if (action.npcName) label += ` · ${action.npcName}`
  return label
}

export function actionSlotHeading(action) {
  if (!action) return ''
  if (action.actionSlot === 0) return '免费搬运 / 快速行动'
  return `行动${action.actionSlot}`
}

/** Combined copy-paste summary for both action slots. */
export function buildPlayerFeedbackSummary(playerName, gameDay, slot1, slot2, freeTransports = []) {
  const day = gameDay ?? ''
  const lines = [`【${playerName} · 第${day}天 行动反馈总结】`, '']
  const slots = [
    { n: '行动一', a: slot1 },
    { n: '行动二', a: slot2 },
  ]
  for (const { n, a } of slots) {
    if (!a) {
      lines.push(`${n}：未提交`, '')
      continue
    }
    lines.push(`${n}（${actionShortLabel(a)}）`)
    const draft = getDmFeedbackDraft(a)
    if (draft) {
      lines.push(draft)
    } else if (a.status === 'feedbacked') {
      lines.push('（已处理，无反馈文案）')
    } else {
      lines.push('（待反馈）')
    }
    lines.push('')
  }
  const extras = Array.isArray(freeTransports) ? freeTransports : []
  extras.forEach((a, i) => {
    const n = extras.length > 1 ? `免费搬运${i + 1}` : '免费搬运'
    lines.push(`${n}（${actionShortLabel(a)} / 快速行动）`)
    const draft = getDmFeedbackDraft(a)
    if (draft) {
      lines.push(draft)
    } else if (a.status === 'feedbacked') {
      lines.push('（已处理，无反馈文案）')
    } else {
      lines.push('（待反馈）')
    }
    lines.push('')
  })
  return lines.join('\n').trim()
}

/**
 * 获取物资图片 url；若没有对应素材返回 null。
 * @param {'item'|'weapon'|'ammo'|'material'} type
 * @param {number|string} id
 * @returns {string | null}
 */
export function getMaterialImageUrl(type, id) {
  if (type == null || id === '' || id === undefined) return null
  const t = String(type).toLowerCase()
  const table = MATERIAL_MAPS[t]
  if (!table) return null
  const numId = typeof id === 'number' && Number.isFinite(id) ? id : parseInt(String(id), 10)
  if (Number.isNaN(numId)) return null
  return table[numId] ?? null
}

/** 无对应素材时返回统一占位图（与 {@link imgMedicalKit} 相同资源） */
export const DEFAULT_MATERIAL_IMAGE_URL = imgMedicalKit

/** 解析结果缓存，避免大量组件重复拼接字符串与查表 */
const materialUrlOrDefaultCache = new Map()

export function getMaterialImageUrlOrDefault(type, id) {
  if (type == null || id === '' || id === undefined) return DEFAULT_MATERIAL_IMAGE_URL
  const t = String(type).toLowerCase()
  const numId = typeof id === 'number' && Number.isFinite(id) ? id : parseInt(String(id), 10)
  if (t === 'material' && numId === 5) return imgFood
  if (t === 'material' && numId === 8) return imgFuel
  if (Number.isNaN(numId)) return DEFAULT_MATERIAL_IMAGE_URL
  const key = `${t}:${numId}`
  let cached = materialUrlOrDefaultCache.get(key)
  if (cached !== undefined) return cached
  cached = getMaterialImageUrl(t, numId) ?? DEFAULT_MATERIAL_IMAGE_URL
  materialUrlOrDefaultCache.set(key, cached)
  return cached
}

/**
 * 空闲时预加载所有物资图 URL（浏览器 HTTP 缓存 + 解码后可更快展示）。
 * 在交易页等入口 mounted 时调用一次即可。
 */
export function preloadMaterialImages() {
  if (typeof Image === 'undefined') return
  const seen = new Set()
  /** @param {string} src */
  const queue = (src) => {
    if (!src || seen.has(src)) return
    seen.add(src)
    const img = new Image()
    img.decoding = 'async'
    img.src = src
  }
  for (const table of Object.values(MATERIAL_MAPS)) {
    for (const url of Object.values(table)) {
      if (typeof url === 'string') queue(url)
    }
  }
  queue(DEFAULT_MATERIAL_IMAGE_URL)
}

/** 筛选标签 / 标题旁的小图（可选） */
export function getTypeTabImage(type) {
  if (type === 'weapon') return imgRifle
  if (type === 'ammo') return imgServicePistol
  if (type === 'material') return imgWood
  return imgMedicalKit
}

// -----------------------------
// 统治者避难所：图鉴 / 库存 / 日志
// -----------------------------
export const SHELTER_ITEM_CATALOG = {
  medical_kit: { id: 'medical_kit', name: '医疗资源', category: 'prop', description: '基础医疗物资，急救重伤需5份。', imageUrl: imgMedicalKit },
  flashlight: { id: 'flashlight', name: '手电筒', category: 'prop', description: '夜间行动照明工具。', imageUrl: imgFlashlight },
  handcuffs: { id: 'handcuffs', name: '手铐', category: 'prop', description: '约束目标行动的控制道具。', imageUrl: imgHandcuffs },
  whistle: { id: 'whistle', name: '哨子', category: 'prop', description: '可用于报警或快速集合。', imageUrl: imgWhistle },
  body_armor: { id: 'body_armor', name: '防弹衣', category: 'prop', description: '在暴力冲突中可将一次「重伤」降级为「受伤」，或将一次「受伤」无效化，每场冲突限用一次。', imageUrl: imgBodyArmor },
  composite_shield: { id: 'composite_shield', name: '复合盾', category: 'prop', description: '降低正面冲突受伤风险。', imageUrl: imgCompositeShield },
  flare_gun: { id: 'flare_gun', name: '信号枪', category: 'prop', description: '发射信号弹，远距离传递信息。', imageUrl: imgFlareGun },
  repair_kit: { id: 'repair_kit', name: '维修工具包', category: 'prop', description: '用于设施与器械维修。', imageUrl: imgRepairKit },
  contract: { id: 'contract', name: '协议书', category: 'prop', description: '用于记录玩家间契约。', imageUrl: imgContract },
  rum: { id: 'rum', name: '朗姆酒', category: 'prop', description: '可作为补给或交易物资。', imageUrl: imgRum },
  herbs: { id: 'herbs', name: '草药', category: 'prop', description: '简易治疗所需药材。', imageUrl: imgHerbs },
  fishing_net: { id: 'fishing_net', name: '渔网', category: 'prop', description: '渔猎行动常用工具。', imageUrl: imgFishingNet },
  candle: { id: 'candle', name: '蜡烛', category: 'prop', description: '基础照明消耗品。', imageUrl: imgCandle },
  rubbing_alcohol: { id: 'rubbing_alcohol', name: '医用酒精', category: 'prop', description: '常见消毒用品。', imageUrl: imgAlcohol },
  matches: { id: 'matches', name: '火柴', category: 'prop', description: '取火工具。', imageUrl: imgMatches },
  pencil: { id: 'pencil', name: '铅笔', category: 'prop', description: '书写记录工具。', imageUrl: imgPencil },
  tattered_chart: { id: 'tattered_chart', name: '破损海图', category: 'prop', description: '可用于航线参考。', imageUrl: imgSeaChart },
  service_pistol: { id: 'service_pistol', name: '制式手枪', category: 'weapon', description: '韦伯利.38口径转轮手枪，英军标准配发。威胁值5，远程武器。', imageUrl: imgServicePistol },
  hunting_shotgun: { id: 'hunting_shotgun', name: '猎枪', category: 'weapon', description: '12号口径单管或双管猎枪，用于狩猎鸟类和小型动物。威胁值6，远程武器。', imageUrl: imgHuntingShotgun },
  baton: { id: 'baton', name: '警棍', category: 'weapon', description: '硬木制成的短棍，长50厘米。威胁值1，非致命武器，可用于制服而非杀死目标。', imageUrl: imgBaton },
  bayonet: { id: 'bayonet', name: '刺刀', category: 'weapon', description: '军用制式刺刀，长约20厘米。威胁值2。', imageUrl: imgBayonet },
  harpoon_spear: { id: 'harpoon_spear', name: '鱼叉 / 矛', category: 'weapon', description: '铁头木柄的捕鱼工具，长110厘米。威胁值3，既可捕鱼也可作为近战武器，渔民的标配。', imageUrl: imgHarpoon },
  hunting_bow: { id: 'hunting_bow', name: '猎弓', category: 'weapon', description: '简单木质主体金属包角的反曲猎弓。威胁值4，无声远程武器。', imageUrl: imgHuntingBow },
  pickaxe: { id: 'pickaxe', name: '十字镐', category: 'weapon', description: '采矿用的双头镐具，长65厘米，重5kg。威胁值1，主要用来挖掘石料，紧急时也可作为武器。', imageUrl: imgPickaxe },
  axe: { id: 'axe', name: '斧头', category: 'weapon', description: '伐木用双面斧，长65厘米。威胁值2，砍树是本职工作，砍人也不是不行。', imageUrl: imgAxe },
  wood: { id: 'wood', name: '木材', category: 'material', description: '基础建造材料。', imageUrl: imgWood },
  stone: { id: 'stone', name: '石料', category: 'material', description: '用于加固结构。', imageUrl: imgStone },
  plank: { id: 'plank', name: '木板', category: 'material', description: '用于铺板和隔断。', imageUrl: imgPlank },
  rope: { id: 'rope', name: '绳索', category: 'material', description: '麻绳或钢丝绳，直径1-2厘米。用于捆绑、拖拽、登山或船只系泊。探索时投入10个可提供+2探索值。', imageUrl: imgRope },
}

export const SHELTER_ITEM_CATALOG_BY_TYPE = {
  'item_1': SHELTER_ITEM_CATALOG.medical_kit,
  'item_2': SHELTER_ITEM_CATALOG.flashlight,
  'item_3': SHELTER_ITEM_CATALOG.handcuffs,
  'item_4': SHELTER_ITEM_CATALOG.whistle,
  'item_5': SHELTER_ITEM_CATALOG.body_armor,
  'item_6': SHELTER_ITEM_CATALOG.composite_shield,
  'item_7': SHELTER_ITEM_CATALOG.flare_gun,
  'item_8': SHELTER_ITEM_CATALOG.repair_kit,
  'item_9': SHELTER_ITEM_CATALOG.contract,
  'item_10': SHELTER_ITEM_CATALOG.rum,
  'item_11': SHELTER_ITEM_CATALOG.herbs,
  'item_12': SHELTER_ITEM_CATALOG.fishing_net,
  'item_13': SHELTER_ITEM_CATALOG.candle,
  'item_14': SHELTER_ITEM_CATALOG.rubbing_alcohol,
  'item_15': SHELTER_ITEM_CATALOG.matches,
  'item_16': SHELTER_ITEM_CATALOG.pencil,
  'item_17': SHELTER_ITEM_CATALOG.tattered_chart,
  'weapon_1': SHELTER_ITEM_CATALOG.service_pistol,
  'weapon_2': SHELTER_ITEM_CATALOG.hunting_shotgun,
  'weapon_3': SHELTER_ITEM_CATALOG.baton,
  'weapon_4': SHELTER_ITEM_CATALOG.bayonet,
  'weapon_6': SHELTER_ITEM_CATALOG.harpoon_spear,
  'weapon_7': SHELTER_ITEM_CATALOG.hunting_bow,
  'weapon_8': SHELTER_ITEM_CATALOG.pickaxe,
  'weapon_9': SHELTER_ITEM_CATALOG.axe,
  'material_2': SHELTER_ITEM_CATALOG.wood,
  'material_3': SHELTER_ITEM_CATALOG.rope,
  'material_4': SHELTER_ITEM_CATALOG.plank,
  'material_7': SHELTER_ITEM_CATALOG.stone,
}

export const SHELTER_DAILY_LOGS = [
  { day: 1, workers: [
    { name: '张三', isProfessional: true, isOppressed: false, value: 5 },
    { name: '李四', isProfessional: false, isOppressed: true, value: 7 },
    { name: '王五', isProfessional: true, isOppressed: true, value: 8 },
    { name: '赵六', isProfessional: false, isOppressed: false, value: 4 },
  ]},
  { day: 2, workers: [
    { name: '孙七', isProfessional: false, isOppressed: false, value: 4 },
    { name: '周八', isProfessional: true, isOppressed: false, value: 5 },
    { name: '张三', isProfessional: true, isOppressed: true, value: 8 },
    { name: '李四', isProfessional: false, isOppressed: false, value: 4 },
    { name: '王五', isProfessional: false, isOppressed: true, value: 7 },
  ]},
  { day: 3, workers: [
    { name: '赵六', isProfessional: true, isOppressed: false, value: 5 },
    { name: '孙七', isProfessional: false, isOppressed: true, value: 7 },
    { name: '周八', isProfessional: true, isOppressed: true, value: 8 },
    { name: '张三', isProfessional: false, isOppressed: false, value: 4 },
  ]},
]

// 将后端库存与图鉴映射成可展示的数据
// 支持两种数据格式：
// 旧格式: { id: 'wood', quantity: 45 }
// 新格式: { itemType: 'material', itemId: 2, quantity: 45 }
export function resolveShelterInventoryRows(items) {
  if (!Array.isArray(items)) return []
  return items
    .filter((row) => row != null)
    .map((row) => {
      if (row.name) {
        const key = row.itemType != null && row.itemId != null
          ? `${row.itemType}_${row.itemId}`
          : String(row.id ?? '')
        const category = { item: 'prop', weapon: 'weapon', ammo: 'ammo', material: 'material' }[row.itemType] || 'prop'
        return {
          id: key,
          itemType: row.itemType,
          itemId: row.itemId,
          name: row.name,
          category,
          description: row.description || '',
          imageUrl: getMaterialImageUrlOrDefault(row.itemType, row.itemId),
          unit: row.unit || '',
          quantity: row.quantity,
        }
      }

      let def = null
      if (row.id != null) {
        def = SHELTER_ITEM_CATALOG[row.id]
      } else if (row.itemType != null && row.itemId != null) {
        const key = `${row.itemType}_${row.itemId}`
        def = SHELTER_ITEM_CATALOG_BY_TYPE[key]
      }
      if (!def) {
        const key = row.itemType != null && row.itemId != null
          ? `${row.itemType}_${row.itemId}`
          : String(row.id ?? '')
        if (!key) return null
        const category = { item: 'prop', weapon: 'weapon', ammo: 'ammo', material: 'material' }[row.itemType] || 'prop'
        return {
          id: key,
          itemType: row.itemType,
          itemId: row.itemId,
          name: getItemDisplayName(row.itemType, row.itemId),
          category,
          description: '',
          imageUrl: getMaterialImageUrlOrDefault(row.itemType, row.itemId),
          unit: '',
          quantity: row.quantity,
        }
      }
      const key = row.itemType != null && row.itemId != null
        ? `${row.itemType}_${row.itemId}`
        : def.id
      return {
        ...def,
        id: key,
        itemType: row.itemType,
        itemId: row.itemId,
        quantity: row.quantity,
      }
    })
    .filter(Boolean)
}

// 计算避难所总建造值
export function shelterTotalBuildValue(logs) {
  if (!Array.isArray(logs)) return 0
  return logs.reduce((sum, day) => sum + (Array.isArray(day?.workers) ? day.workers.reduce((s, worker) => s + (worker?.value || 0), 0) : 0), 0)
}

/** 武器威胁值徽章样式（与物资管理页一致） */
export function getWeaponThreatBadgeClass(level) {
  const n = Number(level) || 0
  if (n >= 8) return 'text-red-400 bg-red-500/20'
  if (n >= 6) return 'text-amber-400 bg-amber-500/20'
  if (n >= 4) return 'text-yellow-400 bg-yellow-500/20'
  return 'text-emerald-400 bg-emerald-500/20'
}

export const PLAYER_NAME_MAX_LENGTH = 50
export const USERNAME_MAX_LENGTH = 50
export const PASSWORD_MAX_LENGTH = 100

/** 避难所劳工建造值（与后端 ShelterLaborCalculator 一致） */
export const SHELTER_LABOR_BASE = 4
export const SHELTER_LABOR_JOB_BONUS = 1
export const SHELTER_LABOR_EXPLOIT_BONUS = 3
export const SHELTER_LABOR_SLACKING_PENALTY = 1

const SHELTER_PRODUCTION_JOB_NAMES = new Set(['渔民', '农户', '伐木工', '矿工', '猎户'])
const SHELTER_PRODUCTION_SKILL_KEYWORDS = ['食物生产', '伐木', '挖掘', '炼铁']

export function isShelterProductionJob(jobName, jobSkills = '') {
  if (jobName && SHELTER_PRODUCTION_JOB_NAMES.has(String(jobName).trim())) return true
  const s = String(jobSkills || '')
  return SHELTER_PRODUCTION_SKILL_KEYWORDS.some((kw) => s.includes(kw))
}

export function calcShelterLaborBuildValue({ productionJob, exploited, escaped, slacking }) {
  if (escaped) return 0
  let v = SHELTER_LABOR_BASE
  if (productionJob) v += SHELTER_LABOR_JOB_BONUS
  if (exploited) v += SHELTER_LABOR_EXPLOIT_BONUS
  if (slacking) v -= SHELTER_LABOR_SLACKING_PENALTY
  return Math.max(0, v)
}

export function shelterLaborTypeLabel(productionJob, exploited) {
  if (exploited && productionJob) return '职业（压榨）'
  if (exploited) return '普通（压榨）'
  if (productionJob) return '职业劳工'
  return '普通劳工'
}

export function shelterLaborBuildBreakdown(productionJob, exploited, escaped, slacking) {
  if (escaped) return '逃役（0）'
  const parts = [`基础${SHELTER_LABOR_BASE}`]
  if (productionJob) parts.push(`职业+${SHELTER_LABOR_JOB_BONUS}`)
  if (exploited) parts.push(`压榨+${SHELTER_LABOR_EXPLOIT_BONUS}`)
  if (slacking) parts.push(`怠工-${SHELTER_LABOR_SLACKING_PENALTY}`)
  return parts.join(' + ')
}

export function refreshShelterLaborRow(row) {
  if (!row) return row
  const productionJob = row.productionJob ?? isShelterProductionJob(row.jobName, row.jobSkills)
  row.productionJob = productionJob
  row.laborType = shelterLaborTypeLabel(productionJob, Boolean(row.exploited))
  row.buildValueBreakdown = shelterLaborBuildBreakdown(productionJob, Boolean(row.exploited), Boolean(row.escaped), Boolean(row.slacking))
  row.buildValue = calcShelterLaborBuildValue({
    productionJob,
    exploited: Boolean(row.exploited),
    escaped: Boolean(row.escaped),
    slacking: Boolean(row.slacking),
  })
  row.computedBuildValue = row.buildValue
  return row
}

