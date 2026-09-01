<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 text-white">
    <div class="max-w-7xl mx-auto px-4 py-6">
      <div class="flex items-center justify-between mb-6">
        <div class="flex items-center gap-4">
          <h1 class="text-2xl font-bold">NPC 管理</h1>
        </div>
        <div class="flex items-center gap-3">
          <button @click="refreshAll" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-lg transition">
            🔄 刷新全部
          </button>
        </div>
      </div>

      <div class="flex items-center gap-2 mb-6">
        <button
          @click="activeTab = 'npc'"
          :class="[
            'px-6 py-3 rounded-lg font-medium transition-all',
            activeTab === 'npc' ? 'bg-blue-600 text-white' : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
          ]"
        >
          👥 NPC信息管理
        </button>
        <button
          @click="activeTab = 'favor'"
          :class="[
            'px-6 py-3 rounded-lg font-medium transition-all',
            activeTab === 'favor' ? 'bg-purple-600 text-white' : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
          ]"
        >
          💝 好感度管理
        </button>
        <button
          @click="activeTab = 'clue'"
          :class="[
            'px-6 py-3 rounded-lg font-medium transition-all',
            activeTab === 'clue' ? 'bg-amber-600 text-white' : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
          ]"
        >
          🔍 特殊线索管理
        </button>
      </div>

      <!-- NPC管理标签页 -->
      <div v-if="activeTab === 'npc'">
        <div class="bg-slate-800/50 rounded-xl p-4 mb-6 backdrop-blur-sm border border-slate-700">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-4 flex-wrap flex-1">
              <div class="flex-1 min-w-[200px]">
                <input
                  v-model="searchKeyword"
                  type="text"
                  placeholder="搜索NPC名称、职业..."
                  class="w-full bg-slate-700 border border-slate-600 rounded-lg px-4 py-2 focus:outline-none focus:border-blue-500"
                />
              </div>
              <div>
                <select v-model="filterLocation" class="bg-slate-700 border border-slate-600 rounded-lg px-4 py-2 focus:outline-none focus:border-blue-500">
                  <option value="">所有地点</option>
                  <option v-for="loc in locations" :key="loc.id" :value="loc.id">{{ loc.name }}</option>
                </select>
              </div>
              <div>
                <select v-model="filterStatus" class="bg-slate-700 border border-slate-600 rounded-lg px-4 py-2 focus:outline-none focus:border-blue-500">
                  <option value="">所有状态</option>
                  <option value="正常">正常</option>
                  <option value="虚弱">虚弱</option>
                  <option value="受伤">受伤</option>
                  <option value="死亡">死亡</option>
                  <option value="失踪">失踪</option>
                  <option value="被捕">被捕</option>
                </select>
              </div>
              <button @click="clearFilters" class="px-3 py-2 bg-slate-600 hover:bg-slate-500 rounded-lg transition text-sm">
                清除筛选
              </button>
            </div>
            <button @click="showCreateModal = true" class="ml-4 px-4 py-2 bg-green-600 hover:bg-green-700 rounded-lg transition flex items-center gap-2">
              <span>➕</span> 新建NPC
            </button>
          </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div class="lg:col-span-1">
            <div class="bg-slate-800/50 rounded-xl p-4 backdrop-blur-sm border border-slate-700">
              <div class="flex items-center justify-between mb-4">
                <h2 class="text-lg font-semibold">NPC 列表</h2>
                <span class="text-sm text-slate-400">{{ filteredNpcs.length }} 个</span>
              </div>
              
              <div class="space-y-3 max-h-[600px] overflow-y-auto">
                <div
                  v-for="npc in filteredNpcs"
                  :key="npc.id"
                  @click="selectNpc(npc)"
                  :class="[
                    'p-4 rounded-lg cursor-pointer transition-all border-2',
                    selectedNpc?.id === npc.id ? 'bg-blue-600/30 border-blue-500' : 'bg-slate-700/50 border-transparent hover:border-slate-600'
                  ]"
                >
                  <div class="flex items-center justify-between mb-2">
                    <span class="font-semibold">{{ npc.name }}</span>
                    <span class="text-xs px-2 py-1 rounded-full" :class="getStatusClass(npc.status)">
                      {{ npc.status || '正常' }}
                    </span>
                  </div>
                  <div class="flex items-center gap-2 text-xs text-slate-400 mb-1">
                    <span class="px-2 py-0.5 bg-slate-600 rounded">{{ npc.job }}</span>
                    <span>📍 {{ npc.locationName }}</span>
                  </div>
                  <div class="flex items-center gap-1 text-xs">
                    <span class="px-1.5 py-0.5 rounded" :class="getAttitudeClass(npc.attitudeRuler)">统治者</span>
                    <span class="px-1.5 py-0.5 rounded" :class="getAttitudeClass(npc.attitudeRebel)">反叛者</span>
                    <span class="px-1.5 py-0.5 rounded" :class="getAttitudeClass(npc.attitudeAdventurer)">冒险者</span>
                    <span class="px-1.5 py-0.5 rounded" :class="getAttitudeClass(npc.attitudeScourge)">天灾</span>
                  </div>
                </div>
              </div>
              
              <div v-if="filteredNpcs.length === 0" class="text-center text-slate-500 py-8">
                <div class="text-4xl mb-2">🔍</div>
                <p>没有找到匹配的NPC</p>
              </div>
            </div>
          </div>

          <div class="lg:col-span-2">
            <div v-if="selectedNpc" class="space-y-6">
              <div class="bg-slate-800/50 rounded-xl backdrop-blur-sm border border-slate-700">
                <div class="p-4 border-b border-slate-700">
                  <div class="flex items-center justify-between">
                    <div class="flex items-center gap-4">
                      <div class="w-16 h-16 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-2xl">
                        {{ selectedNpc.name?.charAt(0) || '?' }}
                      </div>
                      <div>
                        <h2 class="text-xl font-bold">{{ selectedNpc.name }}</h2>
                        <p class="text-slate-400">{{ selectedNpc.job }} · {{ selectedNpc.locationName }}</p>
                      </div>
                    </div>
                    <div class="flex items-center gap-2">
                      <button @click="saveNpcBasicInfo" class="px-4 py-2 bg-green-600 hover:bg-green-700 rounded-lg transition text-sm">
                        💾 保存
                      </button>
                      <button @click="confirmDeleteNpc" class="px-4 py-2 bg-red-600 hover:bg-red-700 rounded-lg transition text-sm">
                        🗑️ 删除
                      </button>
                    </div>
                  </div>
                </div>

                <div class="p-4">
                  <h3 class="font-semibold mb-4 flex items-center gap-2">
                    <span>✏️</span> 基本信息
                  </h3>
                  <div class="grid grid-cols-2 gap-4">
                    <div>
                      <label class="block text-sm text-slate-400 mb-1">姓名</label>
                      <input v-model="editForm.name" type="text" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500" />
                    </div>
                    <div>
                      <label class="block text-sm text-slate-400 mb-1">职业</label>
                      <input v-model="editForm.job" type="text" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500" />
                    </div>
                    <div>
                      <label class="block text-sm text-slate-400 mb-1">性别</label>
                      <select v-model="editForm.gender" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500">
                        <option value="男">男</option>
                        <option value="女">女</option>
                      </select>
                    </div>
                    <div>
                      <label class="block text-sm text-slate-400 mb-1">状态</label>
                      <select v-model="editForm.status" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500">
                  <option value="正常">正常</option>
                  <option value="虚弱">虚弱</option>
                  <option value="受伤">受伤</option>
                  <option value="死亡">死亡</option>
                  <option value="失踪">失踪</option>
                  <option value="被捕">被捕</option>
                      </select>
                    </div>
                    <div>
                      <label class="block text-sm text-slate-400 mb-1">所在地点</label>
                      <select v-model="editForm.locationId" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500">
                        <option v-for="loc in locations" :key="loc.id" :value="loc.id">{{ loc.name }}</option>
                      </select>
                    </div>
                    <div>
                      <label class="block text-sm text-slate-400 mb-1">每日交易上限</label>
                      <input v-model="editForm.dailyTradeLimit" type="number" min="0" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500" />
                    </div>
                    <div class="col-span-2">
                      <label class="block text-sm text-slate-400 mb-1">介绍</label>
                      <textarea v-model="editForm.introduction" rows="3" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500"></textarea>
                    </div>
                    <div class="col-span-2">
                      <label class="block text-sm text-slate-400 mb-1">性格特点</label>
                      <textarea v-model="editForm.personality" rows="2" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500" placeholder="例如：胆怯温和，只想安稳过日子。"></textarea>
                    </div>
                    <div class="col-span-2">
                      <label class="block text-sm text-slate-400 mb-1">对话风格</label>
                      <textarea v-model="editForm.dialogueStyle" rows="3" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500" placeholder="写入 AI 提示词，例如：声音小，经常低头说话……"></textarea>
                    </div>
                  </div>
                </div>
              </div>

              <div class="bg-slate-800/50 rounded-xl backdrop-blur-sm border border-slate-700">
                <div class="p-4 border-b border-slate-700">
                  <h3 class="font-semibold flex items-center gap-2">
                    <span>🔍</span> 特殊线索设置
                  </h3>
                  <p class="text-xs text-slate-400 mt-1">设置当玩家提到特定关键词时，NPC会触发的特殊线索内容</p>
                </div>
                <div class="p-4 space-y-4">
                  <div>
                    <div class="flex items-center justify-between mb-1">
                      <label class="block text-sm text-slate-400">唤醒关键词</label>
                      <div class="flex items-center gap-2">
                        <span class="text-xs text-slate-500">{{ getKeywordList.length }} 个关键词</span>
                        <button v-if="editForm.clueKeywords" @click="clearKeywords" class="text-xs text-red-400 hover:text-red-300">清除全部</button>
                      </div>
                    </div>
                    <textarea
                      v-model="editForm.clueKeywords"
                      rows="3"
                      class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-amber-500"
                      placeholder="输入关键词，多个关键词用逗号（,）分隔&#10;例如：秘密,宝藏,神秘,地图&#10;系统会自动去重处理"
                    ></textarea>
                    <div v-if="getKeywordList.length > 0" class="flex flex-wrap gap-2 mt-2">
                      <span
                        v-for="(kw, idx) in getKeywordList"
                        :key="idx"
                        class="px-2 py-1 bg-amber-600/20 text-amber-300 rounded text-xs"
                      >
                        {{ kw }}
                      </span>
                    </div>
                  </div>

                  <div>
                    <div class="flex items-center justify-between mb-1">
                      <label class="block text-sm text-slate-400">特殊线索内容</label>
                      <div class="flex items-center gap-2">
                        <span class="text-xs text-slate-500">{{ editForm.specialClueContent?.length || 0 }} 字</span>
                        <button v-if="editForm.specialClueContent" @click="clearClueContent" class="text-xs text-red-400 hover:text-red-300">清除</button>
                      </div>
                    </div>
                    <textarea
                      v-model="editForm.specialClueContent"
                      rows="8"
                      class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-amber-500 resize-y"
                      placeholder="当玩家提到上面设置的关键词时，NPC会基于此内容进行回应&#10;支持换行和基本格式，NPC会用口语化的方式自然地传达这些信息"
                    ></textarea>
                    <p class="text-xs text-slate-500 mt-1">
                      提示：线索内容会通过AI转换为符合NPC角色设定的口语化表达，不会直接复述原文
                    </p>
                  </div>

                  <button @click="saveNpcClueInfo" class="w-full py-3 bg-amber-600 hover:bg-amber-700 rounded-lg transition font-semibold">
                    💾 保存线索设置
                  </button>
                </div>
              </div>

              <div class="bg-slate-800/50 rounded-xl backdrop-blur-sm border border-slate-700">
                <div class="p-4 border-b border-slate-700">
                  <h3 class="font-semibold flex items-center gap-2">
                    <span>⚔️</span> 阵营态度倾向
                  </h3>
                  <p class="text-xs text-slate-400 mt-1">设置NPC对各阵营的初始好感度倾向</p>
                </div>
                <div class="p-4">
                  <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <div class="bg-slate-700/50 rounded-lg p-4">
                      <div class="flex items-center gap-2 mb-3">
                        <span class="text-lg">👑</span>
                        <span class="font-medium">统治者</span>
                      </div>
                      <select v-model="editForm.attitudeRuler" class="w-full bg-slate-600 border border-slate-500 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500">
                        <option value="喜好">喜好 (+20)</option>
                        <option value="忽视">忽视 (0)</option>
                        <option value="厌恶">厌恶 (-20)</option>
                      </select>
                    </div>
                    <div class="bg-slate-700/50 rounded-lg p-4">
                      <div class="flex items-center gap-2 mb-3">
                        <span class="text-lg">🔥</span>
                        <span class="font-medium">反叛者</span>
                      </div>
                      <select v-model="editForm.attitudeRebel" class="w-full bg-slate-600 border border-slate-500 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500">
                        <option value="喜好">喜好 (+20)</option>
                        <option value="忽视">忽视 (0)</option>
                        <option value="厌恶">厌恶 (-20)</option>
                      </select>
                    </div>
                    <div class="bg-slate-700/50 rounded-lg p-4">
                      <div class="flex items-center gap-2 mb-3">
                        <span class="text-lg">🧭</span>
                        <span class="font-medium">冒险者</span>
                      </div>
                      <select v-model="editForm.attitudeAdventurer" class="w-full bg-slate-600 border border-slate-500 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500">
                        <option value="喜好">喜好 (+20)</option>
                        <option value="忽视">忽视 (0)</option>
                        <option value="厌恶">厌恶 (-20)</option>
                      </select>
                    </div>
                    <div class="bg-slate-700/50 rounded-lg p-4">
                      <div class="flex items-center gap-2 mb-3">
                        <span class="text-lg">💀</span>
                        <span class="font-medium">天灾使者</span>
                      </div>
                      <select v-model="editForm.attitudeScourge" class="w-full bg-slate-600 border border-slate-500 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500">
                        <option value="喜好">喜好 (+20)</option>
                        <option value="忽视">忽视 (0)</option>
                        <option value="厌恶">厌恶 (-20)</option>
                      </select>
                    </div>
                  </div>
                  <button @click="saveNpcBasicInfo" class="mt-4 w-full py-3 bg-green-600 hover:bg-green-700 rounded-lg transition font-semibold">
                    💾 保存阵营态度
                  </button>
                </div>
              </div>

              <div class="bg-slate-800/50 rounded-xl backdrop-blur-sm border border-slate-700">
                <div class="p-4 border-b border-slate-700">
                  <h3 class="font-semibold flex items-center gap-2">
                    <span>💝</span> 玩家好感度管理
                  </h3>
                </div>
                <div class="p-4">
                  <div class="space-y-3 max-h-[300px] overflow-y-auto">
                    <div v-for="favor in playerFavors" :key="favor.playerId" class="bg-slate-700/50 rounded-lg p-4">
                      <div class="flex items-center justify-between mb-2">
                        <span class="font-medium">{{ favor.playerName }}</span>
                        <span class="text-sm px-3 py-1 rounded-full" :style="{ backgroundColor: getFavorColor(favor.favorValue) + '20', color: getFavorColor(favor.favorValue) }">
                          {{ getFavorLevel(favor.favorValue) }} ({{ favor.favorValue }})
                        </span>
                      </div>
                      <div class="flex items-center gap-3">
                        <input type="range" :min="-100" :max="100" :value="favor.favorValue" @input="handleFavorRangeChange(favor, $event)" class="flex-1 h-2 bg-slate-600 rounded-lg appearance-none cursor-pointer" />
                        <input type="number" :min="-100" :max="100" :value="favor.favorValue" @change="handleFavorInputChange(favor, $event)" class="w-16 bg-slate-700 border border-slate-600 rounded-lg px-2 py-1 text-center focus:outline-none focus:border-blue-500" />
                      </div>
                    </div>
                    <div v-if="playerFavors.length === 0" class="text-center text-slate-500 py-4">
                      暂无玩家好感度数据
                    </div>
                  </div>
                </div>
              </div>

              <div class="bg-slate-800/50 rounded-xl backdrop-blur-sm border border-slate-700">
                <div class="p-4 border-b border-slate-700">
                  <div class="flex items-center justify-between">
                    <h3 class="font-semibold flex items-center gap-2">
                      <span>👤</span> 玩家认识管理
                    </h3>
                    <button @click="openAddRecognitionModal(selectedNpc?.id)" class="px-3 py-1.5 bg-green-600 hover:bg-green-700 rounded-lg text-sm transition">
                      + 建立认识关系
                    </button>
                  </div>
                  <p class="text-xs text-slate-400 mt-1">管理此NPC与玩家的认识关系，玩家需先认识NPC才能进行交流</p>
                </div>
                <div class="p-4">
                  <div class="space-y-3 max-h-[300px] overflow-y-auto">
                    <div v-for="rec in recognitionPlayers" :key="rec.id" class="bg-slate-700/50 rounded-lg p-4">
                      <div class="flex items-center justify-between">
                        <div>
                          <span class="font-medium">{{ rec.playerName }}</span>
                          <span class="text-xs text-slate-400 ml-2">({{ rec.playerFaction }})</span>
                        </div>
                        <div class="flex items-center gap-3">
                          <span class="text-xs text-slate-500">玩家ID: {{ rec.playerId }}</span>
                          <span class="text-xs text-slate-500">认识于: {{ formatDate(rec.recognizedAt) }}</span>
                          <button @click="removeRecognition(rec)" class="px-2 py-1 bg-red-600/30 hover:bg-red-600/50 text-red-400 rounded text-xs">
                            解除关系
                          </button>
                        </div>
                      </div>
                    </div>
                    <div v-if="recognitionPlayers.length === 0" class="text-center text-slate-500 py-4">
                      暂无认识的玩家<br/>
                      <span class="text-xs">点击上方"建立认识关系"按钮添加</span>
                    </div>
                  </div>
                </div>
              </div>

              <div class="bg-slate-800/50 rounded-xl backdrop-blur-sm border border-slate-700">
                <div class="p-4 border-b border-slate-700 flex items-center justify-between">
                  <div>
                    <h3 class="font-semibold flex items-center gap-2">
                      <span>🎒</span> 个人背包
                    </h3>
                    <p class="text-xs text-slate-400 mt-1">交易只能拿出背包里的东西；食物/燃料会预留当日消耗。尸体物资仅DM可改。</p>
                  </div>
                  <div class="flex gap-2">
                    <button @click="seedNpcInventory('add')" class="px-3 py-1 text-xs bg-slate-600 hover:bg-slate-500 rounded-lg">按职业补发</button>
                    <button @click="seedNpcInventory('replace')" class="px-3 py-1 text-xs bg-amber-800 hover:bg-amber-700 rounded-lg">按职业重置</button>
                  </div>
                </div>
                <div class="p-4 space-y-4">
                  <div v-if="npcSurvival" class="text-xs text-slate-300 flex flex-wrap gap-3">
                    <span>食物 {{ npcSurvival.foodKg }} / 需 {{ npcSurvival.requiredFoodUnits }}</span>
                    <span>木材 {{ npcSurvival.woodKg }}kg</span>
                    <span>燃料 {{ npcSurvival.fuelKg }}kg</span>
                    <span>热值 {{ npcSurvival.heatValue }} / {{ npcSurvival.requiredFuelKg }}</span>
                  </div>
                  <div class="space-y-2 max-h-56 overflow-y-auto">
                    <div v-for="item in npcInventory" :key="item.id || (item.itemType + '-' + item.itemId)" class="flex items-center gap-2 bg-slate-700/50 rounded-lg px-3 py-2">
                      <span class="text-sm flex-1">{{ item.itemName }}</span>
                      <span class="text-xs text-slate-500">{{ item.itemType }} #{{ item.itemId }}</span>
                      <input type="number" min="0" :value="item.quantity" @change="onInventoryQty(item, $event)" class="w-20 bg-slate-600 border border-slate-500 rounded px-2 py-1 text-sm text-center" />
                    </div>
                    <p v-if="npcInventory.length === 0" class="text-slate-500 text-sm">背包是空的</p>
                  </div>
                  <div class="flex flex-wrap gap-2 items-end">
                    <select v-model="inventoryAdd.itemType" class="bg-slate-600 border border-slate-500 rounded px-2 py-1 text-sm">
                      <option value="material">物资</option>
                      <option value="item">道具</option>
                      <option value="weapon">武器</option>
                      <option value="ammo">弹药</option>
                    </select>
                    <select v-model="inventoryAdd.itemId" class="bg-slate-600 border border-slate-500 rounded px-2 py-1 text-sm">
                      <option v-for="i in getItemList(inventoryAdd.itemType)" :key="i.id" :value="i.id">{{ i.name }}</option>
                    </select>
                    <input v-model.number="inventoryAdd.quantity" type="number" min="1" class="w-20 bg-slate-600 border border-slate-500 rounded px-2 py-1 text-sm text-center" />
                    <button @click="addInventoryItem" class="px-3 py-1 text-xs bg-green-700 hover:bg-green-600 rounded-lg">加入</button>
                  </div>
                  <div v-if="npcConsumptionHistory.length" class="text-xs text-slate-400 space-y-1">
                    <div class="text-slate-300">消耗记录</div>
                    <div v-for="row in npcConsumptionHistory" :key="row.gameDay">
                      第{{ row.gameDay }}天 {{ row.requirementsMet ? '达标' : '不足' }} → {{ row.resultStatus }}
                      （食{{ row.consumedFoodUnits }}/{{ row.requiredFoodUnits }} 暖{{ row.consumedFuelKg }}/{{ row.requiredFuelKg }}）
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div v-else class="bg-slate-800/50 rounded-xl p-12 text-center border border-slate-700">
              <div class="text-6xl mb-4">👥</div>
              <p class="text-slate-400">选择一个 NPC 进行管理</p>
              <p class="text-slate-500 text-sm mt-2">或点击"新建NPC"创建新的NPC</p>
            </div>
          </div>
        </div>
      </div>

      <!-- 好感度管理标签页 -->
      <div v-if="activeTab === 'favor'" class="space-y-6">
        <div class="flex items-center justify-between flex-wrap gap-4">
          <div class="flex items-center gap-4 flex-wrap">
            <div class="flex-1 min-w-[200px]">
              <input
                v-model="favorSearchKeyword"
                type="text"
                placeholder="搜索NPC或玩家名称..."
                class="w-full bg-slate-700 border border-slate-600 rounded-lg px-4 py-2 focus:outline-none focus:border-purple-500"
              />
            </div>
            <select v-model="favorFilter.npcId" class="bg-slate-700 border border-slate-600 rounded-lg px-4 py-2 focus:outline-none focus:border-purple-500">
              <option value="">所有NPC</option>
              <option v-for="npc in npcs" :key="npc.id" :value="npc.id">{{ npc.name }}</option>
            </select>
            <select v-model="favorFilter.playerId" class="bg-slate-700 border border-slate-600 rounded-lg px-4 py-2 focus:outline-none focus:border-purple-500">
              <option value="">所有玩家</option>
              <option v-for="player in players" :key="player.id" :value="player.id">{{ player.name }} ({{ player.faction }})</option>
            </select>
            <select v-model="favorSort.field" class="bg-slate-700 border border-slate-600 rounded-lg px-4 py-2 focus:outline-none focus:border-purple-500">
              <option value="favorValue">按好感度排序</option>
              <option value="npcName">按NPC名称排序</option>
              <option value="playerName">按玩家名称排序</option>
              <option value="updatedAt">按更新时间排序</option>
            </select>
            <button @click="toggleSortOrder" class="px-4 py-2 bg-slate-700 hover:bg-slate-600 rounded-lg transition">
              {{ favorSort.order === 'asc' ? '↑' : '↓' }}
            </button>
          </div>
          <div class="flex items-center gap-3">
            <button @click="loadFavors" class="px-4 py-2 bg-purple-600 hover:bg-purple-700 rounded-lg transition">
              🔍 筛选
            </button>
            <button @click="showAdjustModal = true" class="px-4 py-2 bg-green-600 hover:bg-green-700 rounded-lg transition">
              ✏️ 调整好感度
            </button>
          </div>
        </div>

        <div class="bg-slate-800/50 rounded-xl p-4 backdrop-blur-sm border border-slate-700">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-semibold">好感度列表</h2>
            <div class="flex items-center gap-4">
              <span class="text-sm text-slate-400">{{ sortedFavors.length }} 条记录</span>
              <div class="flex items-center gap-2 text-xs">
                <span class="px-2 py-1 bg-red-900/50 text-red-400 rounded">敌视</span>
                <span class="px-2 py-1 bg-yellow-900/50 text-yellow-400 rounded">冷漠</span>
                <span class="px-2 py-1 bg-slate-600 text-slate-400 rounded">中立</span>
                <span class="px-2 py-1 bg-blue-900/50 text-blue-400 rounded">友善</span>
                <span class="px-2 py-1 bg-green-900/50 text-green-400 rounded">亲近</span>
              </div>
            </div>
          </div>
          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead>
                <tr class="text-left text-slate-400 border-b border-slate-700">
                  <th class="pb-3 px-2">NPC</th>
                  <th class="pb-3 px-2">玩家</th>
                  <th class="pb-3 px-2">当前好感度</th>
                  <th class="pb-3 px-2">等级</th>
                  <th class="pb-3 px-2">快速调整</th>
                  <th class="pb-3 px-2">操作</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="favor in sortedFavors" :key="favor.id" class="border-b border-slate-700/50 hover:bg-slate-700/30">
                  <td class="py-3 px-2">
                    <div class="font-medium">{{ favor.npcName }}</div>
                    <div class="text-xs text-slate-400">{{ favor.npcJob }}</div>
                  </td>
                  <td class="py-3 px-2">
                    <div class="font-medium">{{ favor.playerName }}</div>
                  </td>
                  <td class="py-3 px-2">
                    <div class="flex items-center gap-2">
                      <div class="w-24 h-2 bg-slate-600 rounded-full overflow-hidden">
                        <div class="h-full transition-all" :style="{ width: `${(favor.favorValue + 100) / 2}%`, backgroundColor: getFavorColor(favor.favorValue) }"></div>
                      </div>
                      <span class="font-medium" :style="{ color: getFavorColor(favor.favorValue) }">{{ favor.favorValue }}</span>
                    </div>
                  </td>
                  <td class="py-3 px-2">
                    <span class="px-2 py-1 rounded-full text-xs" :style="{ backgroundColor: getFavorColor(favor.favorValue) + '20', color: getFavorColor(favor.favorValue) }">
                      {{ favor.favorLevel }}
                    </span>
                  </td>
                  <td class="py-3 px-2">
                    <div class="flex items-center gap-1">
                      <button @click="quickAdjustFavor(favor, -10)" :disabled="favor.favorValue <= -100" :class="[
                        'px-2 py-1 text-xs rounded transition',
                        favor.favorValue <= -100 ? 'bg-slate-600 text-slate-500 cursor-not-allowed' : 'bg-red-600/30 hover:bg-red-600/50 text-red-400'
                      ]">-10</button>
                      <button @click="quickAdjustFavor(favor, -5)" :disabled="favor.favorValue <= -100" :class="[
                        'px-2 py-1 text-xs rounded transition',
                        favor.favorValue <= -100 ? 'bg-slate-600 text-slate-500 cursor-not-allowed' : 'bg-red-600/30 hover:bg-red-600/50 text-red-400'
                      ]">-5</button>
                      <input 
                        type="number" 
                        :value="favor.favorValue" 
                        @change="directAdjustFavor(favor, $event)"
                        min="-100" 
                        max="100" 
                        class="w-16 bg-slate-700 border border-slate-600 rounded px-2 py-1 text-xs text-center focus:outline-none focus:border-blue-500" 
                      />
                      <button @click="quickAdjustFavor(favor, 5)" :disabled="favor.favorValue >= 100" :class="[
                        'px-2 py-1 text-xs rounded transition',
                        favor.favorValue >= 100 ? 'bg-slate-600 text-slate-500 cursor-not-allowed' : 'bg-green-600/30 hover:bg-green-600/50 text-green-400'
                      ]">+5</button>
                      <button @click="quickAdjustFavor(favor, 10)" :disabled="favor.favorValue >= 100" :class="[
                        'px-2 py-1 text-xs rounded transition',
                        favor.favorValue >= 100 ? 'bg-slate-600 text-slate-500 cursor-not-allowed' : 'bg-green-600/30 hover:bg-green-600/50 text-green-400'
                      ]">+10</button>
                    </div>
                  </td>
                  <td class="py-3 px-2">
                    <button @click="openAdjustModal(favor)" class="px-3 py-1 bg-purple-600/30 hover:bg-purple-600/50 rounded text-xs">详情</button>
                  </td>
                </tr>
                <tr v-if="sortedFavors.length === 0">
                  <td colspan="6" class="py-8 text-center text-slate-500">暂无好感度数据</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div class="bg-slate-800/50 rounded-xl p-4 backdrop-blur-sm border border-slate-700">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-semibold">好感度调整记录</h2>
            <button @click="loadAdjustmentHistory" class="px-3 py-1 bg-slate-600 hover:bg-slate-500 rounded text-xs">刷新记录</button>
          </div>
          <div class="overflow-x-auto max-h-[400px] overflow-y-auto">
            <table class="w-full text-sm">
              <thead class="sticky top-0 bg-slate-800">
                <tr class="text-left text-slate-400 border-b border-slate-700">
                  <th class="pb-2 px-2">时间</th>
                  <th class="pb-2 px-2">NPC</th>
                  <th class="pb-2 px-2">玩家</th>
                  <th class="pb-2 px-2">操作人</th>
                  <th class="pb-2 px-2">变化</th>
                  <th class="pb-2 px-2">原因</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="record in adjustmentHistory" :key="record.id" class="border-b border-slate-700/50 hover:bg-slate-700/30">
                  <td class="py-2 px-2 text-slate-400 text-xs">{{ formatDate(record.createdAt) }}</td>
                  <td class="py-2 px-2">{{ record.npcName }}</td>
                  <td class="py-2 px-2">{{ record.playerName }}</td>
                  <td class="py-2 px-2">{{ record.operatorName }}</td>
                  <td class="py-2 px-2">
                    <span class="font-medium">{{ record.oldValue }} → {{ record.newValue }}</span>
                    <span class="ml-2 text-xs" :class="record.changeAmount > 0 ? 'text-green-400' : record.changeAmount < 0 ? 'text-red-400' : 'text-slate-400'">
                      ({{ record.changeAmount > 0 ? '+' : '' }}{{ record.changeAmount }})
                    </span>
                  </td>
                  <td class="py-2 px-2 text-slate-400 text-xs max-w-[200px] truncate">{{ record.adjustmentReason || '-' }}</td>
                </tr>
                <tr v-if="adjustmentHistory.length === 0">
                  <td colspan="6" class="py-8 text-center text-slate-500">暂无调整记录</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- 创建NPC弹窗 -->
    <div v-if="showCreateModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="bg-slate-800 rounded-xl p-6 max-w-lg w-full mx-4 border border-slate-700">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-bold">创建新NPC</h3>
          <button @click="showCreateModal = false" class="text-slate-400 hover:text-white">✕</button>
        </div>
        <div class="space-y-4">
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm text-slate-400 mb-1">姓名 *</label>
              <input v-model="createForm.name" type="text" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500" />
            </div>
            <div>
              <label class="block text-sm text-slate-400 mb-1">职业 *</label>
              <input v-model="createForm.job" type="text" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500" />
            </div>
            <div>
              <label class="block text-sm text-slate-400 mb-1">性别</label>
              <select v-model="createForm.gender" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500">
                <option value="男">男</option>
                <option value="女">女</option>
              </select>
            </div>
            <div>
              <label class="block text-sm text-slate-400 mb-1">所在地点 *</label>
              <select v-model="createForm.locationId" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500">
                <option v-for="loc in locations" :key="loc.id" :value="loc.id">{{ loc.name }}</option>
              </select>
            </div>
          </div>
          <div>
            <label class="block text-sm text-slate-400 mb-1">介绍</label>
            <textarea v-model="createForm.introduction" rows="2" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500"></textarea>
          </div>
          <div class="flex items-center gap-3 pt-4">
            <button @click="createNpc" class="flex-1 py-2 bg-green-600 hover:bg-green-700 rounded-lg transition">创建</button>
            <button @click="showCreateModal = false" class="flex-1 py-2 bg-slate-600 hover:bg-slate-500 rounded-lg transition">取消</button>
          </div>
        </div>
      </div>
    </div>

    <!-- 好感度调整弹窗 -->
    <!-- 特殊线索管理标签页 -->
      <div v-if="activeTab === 'clue'" class="space-y-6">
        <div class="bg-slate-800/50 rounded-xl p-4 backdrop-blur-sm border border-slate-700">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-4 flex-wrap">
              <input
                v-model="clueSearchKeyword"
                type="text"
                placeholder="搜索线索编码、关键词..."
                class="bg-slate-700 border border-slate-600 rounded-lg px-4 py-2 focus:outline-none focus:border-amber-500"
              />
              <select v-model="clueFilterActive" class="bg-slate-700 border border-slate-600 rounded-lg px-4 py-2 focus:outline-none focus:border-amber-500">
                <option value="">全部状态</option>
                <option :value="true">已启用</option>
                <option :value="false">已禁用</option>
              </select>
              <button @click="loadClues" class="px-4 py-2 bg-amber-600 hover:bg-amber-700 rounded-lg transition">🔍 搜索</button>
            </div>
            <div class="flex items-center gap-3">
              <button @click="exportClues" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-lg transition">📥 导出</button>
              <button @click="showImportModal = true" class="px-4 py-2 bg-cyan-600 hover:bg-cyan-700 rounded-lg transition">📤 导入</button>
              <button @click="showCreateClueModal = true" class="px-4 py-2 bg-green-600 hover:bg-green-700 rounded-lg transition flex items-center gap-2">
                <span>➕</span> 新建线索
              </button>
            </div>
          </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div class="lg:col-span-1">
            <div class="bg-slate-800/50 rounded-xl p-4 backdrop-blur-sm border border-slate-700">
              <h3 class="font-semibold mb-4">线索列表</h3>
              <div class="space-y-3 max-h-[600px] overflow-y-auto">
                <div
                  v-for="clue in filteredClues"
                  :key="clue.id"
                  @click="selectClue(clue)"
                  :class="[
                    'p-4 rounded-lg cursor-pointer transition-all border-2',
                    selectedClue?.id === clue.id ? 'bg-amber-600/30 border-amber-500' : 'bg-slate-700/50 border-transparent hover:border-slate-600'
                  ]"
                >
                  <div class="flex items-center justify-between mb-2">
                    <span class="font-semibold text-amber-400">{{ clue.clueCode }}</span>
                    <span class="text-xs px-2 py-1 rounded-full" :class="clue.isActive ? 'bg-green-900/50 text-green-400' : 'bg-red-900/50 text-red-400'">
                      {{ clue.isActive ? '启用' : '禁用' }}
                    </span>
                  </div>
                  <div class="text-sm text-slate-300 mb-2">{{ clue.description || '无描述' }}</div>
                  <div class="flex items-center gap-2 text-xs text-slate-400">
                    <span>触发率: {{ clue.probabilityWeight }}%</span>
                    <span>冷却: {{ clue.cooldownMinutes }}分钟</span>
                  </div>
                </div>
                <div v-if="clues.length === 0" class="text-center text-slate-500 py-8">暂无线索</div>
              </div>
            </div>
          </div>

          <div class="lg:col-span-2">
            <div v-if="selectedClue" class="space-y-4">
              <div class="bg-slate-800/50 rounded-xl p-4 backdrop-blur-sm border border-slate-700">
                <div class="flex items-center justify-between mb-4">
                  <h3 class="font-semibold text-xl">{{ selectedClue.clueCode }}</h3>
                  <div class="flex items-center gap-2">
                    <button @click="toggleClueActive" class="px-3 py-1.5 rounded-lg text-sm transition" :class="selectedClue.isActive ? 'bg-red-600/30 hover:bg-red-600/50 text-red-400' : 'bg-green-600/30 hover:bg-green-600/50 text-green-400'">
                      {{ selectedClue.isActive ? '禁用' : '启用' }}
                    </button>
                    <button @click="showEditClueModal = true" class="px-3 py-1.5 bg-blue-600 hover:bg-blue-700 rounded-lg text-sm transition">编辑</button>
                    <button @click="confirmDeleteClue" class="px-3 py-1.5 bg-red-600 hover:bg-red-700 rounded-lg text-sm transition">删除</button>
                  </div>
                </div>

                <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
                  <div class="bg-slate-700/50 rounded-lg p-3">
                    <div class="text-xs text-slate-400">匹配模式</div>
                    <div class="font-medium">{{ selectedClue.matchMode === 'EXACT' ? '精确匹配' : '模糊匹配' }}</div>
                  </div>
                  <div class="bg-slate-700/50 rounded-lg p-3">
                    <div class="text-xs text-slate-400">触发概率</div>
                    <div class="font-medium">{{ selectedClue.probabilityWeight }}%</div>
                  </div>
                  <div class="bg-slate-700/50 rounded-lg p-3">
                    <div class="text-xs text-slate-400">冷却时间</div>
                    <div class="font-medium">{{ selectedClue.cooldownMinutes }}分钟</div>
                  </div>
                  <div class="bg-slate-700/50 rounded-lg p-3">
                    <div class="text-xs text-slate-400">优先级</div>
                    <div class="font-medium">{{ selectedClue.priority }}</div>
                  </div>
                </div>

                <div class="mb-4">
                  <div class="text-xs text-slate-400 mb-2">唤醒关键词</div>
                  <div class="bg-slate-700/50 rounded-lg p-4 font-mono text-sm text-amber-300">
                    {{ selectedClue.keywords }}
                  </div>
                </div>

                <div>
                  <div class="text-xs text-slate-400 mb-2">线索内容</div>
                  <div class="bg-slate-700/50 rounded-lg p-4 text-slate-200 leading-relaxed">
                    {{ selectedClue.content }}
                  </div>
                </div>
              </div>

              <div class="bg-slate-800/50 rounded-xl p-4 backdrop-blur-sm border border-slate-700">
                <div class="flex items-center justify-between mb-4">
                  <h3 class="font-semibold">触发日志</h3>
                  <button @click="loadClueLogs" class="px-3 py-1 bg-slate-600 hover:bg-slate-500 rounded text-xs">刷新</button>
                </div>
                <div class="max-h-[300px] overflow-y-auto">
                  <table class="w-full text-sm">
                    <thead>
                      <tr class="text-left text-slate-400 border-b border-slate-700">
                        <th class="pb-2">时间</th>
                        <th class="pb-2">玩家</th>
                        <th class="pb-2">NPC</th>
                        <th class="pb-2">匹配关键词</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="log in clueLogs" :key="log.id" class="border-b border-slate-700/50">
                        <td class="py-2 text-slate-400 text-xs">{{ formatDate(log.triggerTime) }}</td>
                        <td class="py-2">{{ log.playerId }}</td>
                        <td class="py-2">{{ log.npcId }}</td>
                        <td class="py-2 text-amber-400">{{ log.matchedKeyword }}</td>
                      </tr>
                      <tr v-if="clueLogs.length === 0">
                        <td colspan="4" class="py-4 text-center text-slate-500">暂无触发记录</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>

            <div v-else class="bg-slate-800/50 rounded-xl p-12 text-center border border-slate-700">
              <div class="text-6xl mb-4">🔍</div>
              <p class="text-slate-400">选择一个特殊线索进行管理</p>
              <p class="text-slate-500 text-sm mt-2">或点击"新建线索"创建新的特殊线索</p>
            </div>
          </div>
        </div>
      </div>

      <!-- 创建/编辑线索弹窗 -->
      <div v-if="showCreateClueModal || showEditClueModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
        <div class="bg-slate-800 rounded-xl p-6 max-w-2xl w-full mx-4 border border-slate-700 max-h-[90vh] overflow-y-auto">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-bold">{{ showEditClueModal ? '编辑特殊线索' : '创建特殊线索' }}</h3>
            <button @click="closeClueModal" class="text-slate-400 hover:text-white">✕</button>
          </div>

          <div class="space-y-4">
            <div>
              <label class="block text-sm text-slate-400 mb-1">线索编码（可选，自动生成）</label>
              <input v-model="clueForm.clueCode" type="text" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-amber-500" placeholder="CLUE_XXX" />
            </div>

            <div>
              <label class="block text-sm text-slate-400 mb-1">线索描述（可选）</label>
              <input v-model="clueForm.description" type="text" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-amber-500" placeholder="简短描述这条线索的用途" />
            </div>

            <div>
              <label class="block text-sm text-slate-400 mb-1">唤醒关键词 <span class="text-red-400">*</span></label>
              <textarea v-model="clueForm.keywords" rows="3" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-amber-500" placeholder="多个关键词用逗号、分号或换行分隔&#10;区分大小写，匹配模式决定是否忽略大小写"></textarea>
            </div>

            <div>
              <label class="block text-sm text-slate-400 mb-1">线索内容 <span class="text-red-400">*</span></label>
              <textarea v-model="clueForm.content" rows="5" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-amber-500" placeholder="当玩家触发关键词时，NPC将基于此内容进行回应&#10;支持富文本格式和简单变量"></textarea>
            </div>

            <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div>
                <label class="block text-sm text-slate-400 mb-1">匹配模式</label>
                <select v-model="clueForm.matchMode" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-amber-500">
                  <option value="EXACT">精确匹配（区分大小写）</option>
                  <option value="FUZZY">模糊匹配（忽略大小写）</option>
                </select>
              </div>
              <div>
                <label class="block text-sm text-slate-400 mb-1">触发概率 (%)</label>
                <input v-model.number="clueForm.probabilityWeight" type="number" min="0" max="100" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-amber-500" />
              </div>
              <div>
                <label class="block text-sm text-slate-400 mb-1">冷却时间 (分钟)</label>
                <input v-model.number="clueForm.cooldownMinutes" type="number" min="0" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-amber-500" />
              </div>
              <div>
                <label class="block text-sm text-slate-400 mb-1">优先级</label>
                <input v-model.number="clueForm.priority" type="number" min="0" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-amber-500" />
              </div>
            </div>

            <div class="flex items-center gap-3 pt-4">
              <button @click="saveClue" class="flex-1 py-3 bg-green-600 hover:bg-green-700 rounded-lg transition font-semibold">保存</button>
              <button @click="closeClueModal" class="flex-1 py-3 bg-slate-600 hover:bg-slate-500 rounded-lg transition">取消</button>
            </div>
          </div>
        </div>
      </div>

      <!-- 导入线索弹窗 -->
      <div v-if="showImportModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
        <div class="bg-slate-800 rounded-xl p-6 max-w-lg w-full mx-4 border border-slate-700">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-bold">导入特殊线索</h3>
            <button @click="showImportModal = false" class="text-slate-400 hover:text-white">✕</button>
          </div>
          <div class="space-y-4">
            <div class="bg-amber-900/30 border border-amber-500/50 rounded-lg p-3">
              <p class="text-sm text-amber-300">请将导出的JSON数据粘贴到下方文本框中，系统将自动识别并导入。</p>
            </div>
            <textarea v-model="importData" rows="10" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-amber-500 font-mono text-xs" placeholder="粘贴JSON数据..."></textarea>
            <div class="flex items-center gap-3">
              <button @click="doImport" class="flex-1 py-3 bg-green-600 hover:bg-green-700 rounded-lg transition font-semibold">导入</button>
              <button @click="showImportModal = false" class="flex-1 py-3 bg-slate-600 hover:bg-slate-500 rounded-lg transition">取消</button>
            </div>
          </div>
        </div>
      </div>

      <!-- 建立认识关系弹窗 -->
      <div v-if="showAddRecognitionModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
        <div class="bg-slate-800 rounded-xl p-6 max-w-lg w-full mx-4 border border-slate-700">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-bold">👤 建立认识关系</h3>
            <button @click="showAddRecognitionModal = false" class="text-slate-400 hover:text-white">✕</button>
          </div>
          <div class="space-y-4">
            <div class="bg-amber-900/30 border border-amber-500/50 rounded-lg p-3">
              <p class="text-sm text-amber-300">让 <span class="font-bold">{{ selectedRecognitionNpc?.name }}</span> 认识指定玩家</p>
            </div>
            <div>
              <label class="block text-sm text-slate-400 mb-1">选择玩家 *</label>
              <select v-model="addRecognitionForm.playerId" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-green-500">
                <option value="">请选择玩家</option>
                <option v-for="player in players" :key="player.id" :value="player.id">{{ player.name }} ({{ player.faction }})</option>
              </select>
            </div>
            <div class="flex items-center gap-3">
              <button @click="confirmAddRecognition" class="flex-1 py-3 bg-green-600 hover:bg-green-700 rounded-lg transition font-semibold">确认建立</button>
              <button @click="showAddRecognitionModal = false" class="flex-1 py-3 bg-slate-600 hover:bg-slate-500 rounded-lg transition">取消</button>
            </div>
          </div>
        </div>
      </div>

      <div v-if="showAdjustModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
        <div class="bg-slate-800 rounded-xl p-6 max-w-lg w-full mx-4 border border-slate-700">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-bold">💝 调整好感度</h3>
            <button @click="showAdjustModal = false" class="text-slate-400 hover:text-white">✕</button>
        </div>
        <div class="space-y-4">
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm text-slate-400 mb-1">选择NPC *</label>
              <select v-model="adjustForm.npcId" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-purple-500">
                <option value="">请选择NPC</option>
                <option v-for="npc in npcs" :key="npc.id" :value="npc.id">{{ npc.name }}</option>
              </select>
            </div>
            <div>
              <label class="block text-sm text-slate-400 mb-1">选择玩家 *</label>
              <select v-model="adjustForm.playerId" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-purple-500">
                <option value="">请选择玩家</option>
                <option v-for="player in players" :key="player.id" :value="player.id">{{ player.name }} ({{ player.faction }})</option>
              </select>
            </div>
          </div>

          <div class="bg-slate-700/50 rounded-lg p-4">
            <div class="flex items-center justify-between mb-3">
              <label class="text-sm text-slate-400">好感度值</label>
              <span class="text-2xl font-bold" :style="{ color: getFavorColor(adjustForm.newValue) }">{{ adjustForm.newValue }}</span>
            </div>
            <input type="range" v-model.number="adjustForm.newValue" min="-100" max="100" class="w-full h-3 bg-slate-600 rounded-lg appearance-none cursor-pointer accent-purple-500 mb-3" />
            <div class="flex justify-between text-xs text-slate-500 mb-3">
              <span>-100 敌视</span>
              <span>-50</span>
              <span>0 中立</span>
              <span>+50</span>
              <span>+100 亲近</span>
            </div>
            <div class="flex items-center justify-between text-sm">
              <span class="text-slate-400">好感度等级：</span>
              <span class="px-3 py-1 rounded-full text-sm" :style="{ backgroundColor: getFavorColor(adjustForm.newValue) + '20', color: getFavorColor(adjustForm.newValue) }">
                {{ getFavorLevel(adjustForm.newValue) }}
              </span>
            </div>
            <div v-if="adjustForm.oldValue !== null" class="mt-2 text-sm text-slate-400">
              当前值：{{ adjustForm.oldValue }} → 调整后：{{ adjustForm.newValue }}
              <span :class="adjustForm.newValue - adjustForm.oldValue > 0 ? 'text-green-400' : adjustForm.newValue - adjustForm.oldValue < 0 ? 'text-red-400' : ''">
                ({{ adjustForm.newValue - adjustForm.oldValue > 0 ? '+' : '' }}{{ adjustForm.newValue - adjustForm.oldValue }})
              </span>
            </div>
          </div>

          <div>
            <label class="block text-sm text-slate-400 mb-1">调整原因 *</label>
            <select v-model="adjustForm.reasonType" class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-purple-500 mb-2">
              <option value="">请选择调整原因类型</option>
              <option value="任务完成">任务完成</option>
              <option value="任务失败">任务失败</option>
              <option value="对话互动">对话互动</option>
              <option value="赠送物品">赠送物品</option>
              <option value="交易行为">交易行为</option>
              <option value="剧情事件">剧情事件</option>
              <option value="DM调整">DM手动调整</option>
              <option value="其他">其他</option>
            </select>
            <textarea v-model="adjustForm.reason" rows="2" placeholder="请输入详细的调整原因（必填）..." class="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 focus:outline-none focus:border-purple-500"></textarea>
          </div>

          <div class="flex items-center gap-3 pt-4">
            <button @click="confirmAdjustFavor" :disabled="!canAdjust" :class="[
              'flex-1 py-3 rounded-lg font-semibold transition-all',
              canAdjust ? 'bg-purple-600 hover:bg-purple-700' : 'bg-slate-600 cursor-not-allowed opacity-50'
            ]">
              ✅ 确认调整
            </button>
            <button @click="showAdjustModal = false" class="flex-1 py-3 bg-slate-600 hover:bg-slate-500 rounded-lg transition">取消</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { npcAPI, specialClueAPI } from '../utils/api'

const npcs = ref([])
const locations = ref([])
const selectedNpc = ref(null)
const playerFavors = ref([])
const npcStats = ref({})
const editForm = ref({})
const npcInventory = ref([])
const npcSurvival = ref(null)
const npcConsumptionHistory = ref([])
const inventoryAdd = ref({ itemType: 'material', itemId: 5, quantity: 1 })

const showCreateModal = ref(false)
const createForm = ref({
  name: '',
  job: '',
  gender: '男',
  locationId: null,
  introduction: ''
})

const activeTab = ref('npc')
const players = ref([])
const allFavors = ref([])
const adjustmentHistory = ref([])
const showAdjustModal = ref(false)
const favorFilter = ref({ npcId: '', playerId: '' })
const favorSearchKeyword = ref('')
const favorSort = ref({ field: 'favorValue', order: 'desc' })
const adjustForm = ref({
  npcId: '',
  playerId: '',
  newValue: 0,
  oldValue: null,
  reasonType: '',
  reason: ''
})

const clues = ref([])
const selectedClue = ref(null)
const clueSearchKeyword = ref('')
const clueFilterActive = ref('')
const clueLogs = ref([])
const showCreateClueModal = ref(false)
const showEditClueModal = ref(false)

const recognitionPlayers = ref([])
const recognitionFilter = ref({ npcId: '', playerName: '' })
const selectedRecognitionNpc = ref(null)
const showAddRecognitionModal = ref(false)
const addRecognitionForm = ref({
  npcId: '',
  playerId: ''
})
const showImportModal = ref(false)
const importData = ref('')
const clueForm = ref({
  clueCode: '',
  description: '',
  keywords: '',
  content: '',
  matchMode: 'EXACT',
  probabilityWeight: 50,
  cooldownMinutes: 5,
  priority: 0,
  isActive: true
})

const filteredClues = computed(() => {
  return clues.value.filter(clue => {
    const matchKeyword = !clueSearchKeyword.value || 
      clue.clueCode.toLowerCase().includes(clueSearchKeyword.value.toLowerCase()) ||
      clue.keywords.toLowerCase().includes(clueSearchKeyword.value.toLowerCase()) ||
      (clue.description && clue.description.toLowerCase().includes(clueSearchKeyword.value.toLowerCase()))
    const matchActive = clueFilterActive.value === '' || clue.isActive === (clueFilterActive.value === 'true')
    return matchKeyword && matchActive
  })
})

const searchKeyword = ref('')
const filterLocation = ref('')
const filterStatus = ref('')

const filteredNpcs = computed(() => {
  return npcs.value.filter(npc => {
    const matchKeyword = !searchKeyword.value || npc.name.toLowerCase().includes(searchKeyword.value.toLowerCase()) || npc.job.toLowerCase().includes(searchKeyword.value.toLowerCase())
    const matchLocation = !filterLocation.value || npc.locationId === parseInt(filterLocation.value)
    const matchStatus = !filterStatus.value || npc.status === filterStatus.value
    return matchKeyword && matchLocation && matchStatus
  })
})

const filteredFavors = computed(() => {
  return allFavors.value.filter(favor => {
    const matchNpc = !favorFilter.value.npcId || favor.npcId === parseInt(favorFilter.value.npcId)
    const matchPlayer = !favorFilter.value.playerId || favor.playerId === parseInt(favorFilter.value.playerId)
    const matchKeyword = !favorSearchKeyword.value || 
      favor.npcName.toLowerCase().includes(favorSearchKeyword.value.toLowerCase()) || 
      favor.playerName.toLowerCase().includes(favorSearchKeyword.value.toLowerCase())
    return matchNpc && matchPlayer && matchKeyword
  })
})

const sortedFavors = computed(() => {
  const list = [...filteredFavors.value]
  const field = favorSort.value.field
  const order = favorSort.value.order === 'asc' ? 1 : -1
  
  list.sort((a, b) => {
    let va = a[field]
    let vb = b[field]
    
    if (typeof va === 'string') va = va.toLowerCase()
    if (typeof vb === 'string') vb = vb.toLowerCase()
    
    if (va < vb) return -order
    if (va > vb) return order
    return 0
  })
  
  return list
})

const canAdjust = computed(() => {
  return adjustForm.value.npcId && adjustForm.value.playerId && (adjustForm.value.reasonType || adjustForm.value.reason)
})

const getKeywordList = computed(() => {
  if (!editForm.value.clueKeywords) return []
  const rawKeywords = editForm.value.clueKeywords.split(/[,，;；、\n\r]/)
  const unique = [...new Set(rawKeywords.map(k => k.trim()).filter(k => k))]
  return unique
})

const itemCatalog = {
  material: [
    { id: 1, name: '金属制品' }, { id: 2, name: '木材' }, { id: 3, name: '绳索' },
    { id: 4, name: '木板' }, { id: 5, name: '食物' }, { id: 6, name: '沥青' },
    { id: 7, name: '石料' }, { id: 8, name: '燃料' }, { id: 9, name: '帆布' },
    { id: 10, name: '发动机' }, { id: 11, name: '螺旋桨' }, { id: 12, name: '发电机' }
  ],
  item: [
    { id: 1, name: '医疗资源' }, { id: 2, name: '手电筒' }, { id: 4, name: '哨子' },
    { id: 8, name: '维修工具包' }, { id: 10, name: '朗姆酒' }, { id: 12, name: '渔网' },
    { id: 15, name: '点火工具' }
  ],
  weapon: [
    { id: 1, name: '制式手枪' }, { id: 2, name: '猎枪' }, { id: 3, name: '警棍' },
    { id: 4, name: '刺刀' }, { id: 9, name: '斧头' }, { id: 11, name: '手术刀' }
  ],
  ammo: [
    { id: 1, name: '手枪弹' }, { id: 2, name: '猎枪弹' }, { id: 3, name: '信号弹' }
  ]
}

async function refreshAll() {
  await Promise.all([refreshNpcs(), loadFavors(), loadPlayers()])
}

async function refreshNpcs() {
  const [npcData, locData, statsData] = await Promise.all([
    npcAPI.getAllNpcsForDm(),
    npcAPI.getAllLocations(),
    npcAPI.getNpcStats()
  ])
  if (npcData) npcs.value = npcData
  if (locData) locations.value = locData
  if (statsData) npcStats.value = statsData
}

async function selectNpc(npc) {
  selectedNpc.value = npc
  editForm.value = {
    id: npc.id,
    name: npc.name,
    job: npc.job,
    gender: npc.gender,
    personality: npc.personality || '',
    introduction: npc.introduction || '',
    status: npc.status || '正常',
    dialogueStyle: npc.dialogueStyle || '',
    locationId: npc.locationId,
    dailyTradeLimit: npc.dailyTradeLimit || 1,
    attitudeRuler: npc.attitudeRuler || '忽视',
    attitudeRebel: npc.attitudeRebel || '忽视',
    attitudeAdventurer: npc.attitudeAdventurer || '忽视',
    attitudeScourge: npc.attitudeScourge || '忽视',
    clueKeywords: npc.clueKeywords || '',
    specialClueContent: npc.specialClueContent || ''
  }
  await loadPlayerFavors(npc.id)
  await loadRecognitionPlayers(npc.id)
  await loadNpcInventory(npc.id)
}

async function loadPlayerFavors(npcId) {
  const data = await npcAPI.getFavorsByNpc(npcId)
  if (data) {
    playerFavors.value = data
  }
}

async function saveNpcBasicInfo() {
  if (!selectedNpc.value) return
  const result = await npcAPI.updateNpc(editForm.value)
  if (result?.success) {
    alert('NPC信息保存成功')
    await refreshNpcs()
    const updated = npcs.value.find(n => n.id === selectedNpc.value.id)
    if (updated) selectNpc(updated)
  } else {
    alert(result?.message || '保存失败')
  }
}

async function saveNpcClueInfo() {
  if (!selectedNpc.value) return

  if (getKeywordList.value.length > 0 && (!editForm.value.specialClueContent || editForm.value.specialClueContent.trim() === '')) {
    alert('请填写特殊线索内容，或删除所有关键词')
    return
  }

  const deduplicatedKeywords = getKeywordList.value.join(', ')

  const result = await npcAPI.updateNpc({
    id: editForm.value.id,
    clueKeywords: deduplicatedKeywords,
    specialClueContent: editForm.value.specialClueContent
  })
  if (result?.success) {
    alert('特殊线索设置保存成功')
    editForm.value.clueKeywords = deduplicatedKeywords
    await refreshNpcs()
    const updated = npcs.value.find(n => n.id === selectedNpc.value.id)
    if (updated) {
      updated.clueKeywords = deduplicatedKeywords
      updated.specialClueContent = editForm.value.specialClueContent
      selectedNpc.value = updated
    }
  } else {
    alert(result?.message || '保存失败')
  }
}

function clearKeywords() {
  if (confirm('确定要清除所有关键词吗？')) {
    editForm.value.clueKeywords = ''
  }
}

function clearClueContent() {
  if (confirm('确定要清除特殊线索内容吗？')) {
    editForm.value.specialClueContent = ''
  }
}

async function confirmDeleteNpc() {
  if (!selectedNpc.value) return
  if (!confirm(`确定要删除NPC "${selectedNpc.value.name}" 吗？此操作不可恢复！`)) return
  const result = await npcAPI.deleteNpc(selectedNpc.value.id)
  if (result?.success) {
    alert('NPC已删除')
    selectedNpc.value = null
    await refreshNpcs()
  } else {
    alert(result?.message || '删除失败')
  }
}

async function createNpc() {
  if (!createForm.value.name || !createForm.value.job || !createForm.value.locationId) {
    alert('请填写必填字段：姓名、职业、所在地点')
    return
  }
  const result = await npcAPI.createNpc(createForm.value)
  if (result?.success) {
    alert('NPC创建成功')
    showCreateModal.value = false
    createForm.value = { name: '', job: '', gender: '男', locationId: null, introduction: '' }
    await refreshNpcs()
  } else {
    alert(result?.message || '创建失败')
  }
}

function clearFilters() {
  searchKeyword.value = ''
  filterLocation.value = ''
  filterStatus.value = ''
}

async function loadPlayers() {
  const data = await npcAPI.getAllPlayers()
  if (data) players.value = data
}

async function loadFavors() {
  const data = await npcAPI.getAllFavors()
  if (data) allFavors.value = data
}

async function loadAdjustmentHistory() {
  const data = await npcAPI.getFavorAdjustments(
    favorFilter.value.npcId || null,
    favorFilter.value.playerId || null
  )
  if (data && data.records) adjustmentHistory.value = data.records
}

function toggleSortOrder() {
  favorSort.value.order = favorSort.value.order === 'asc' ? 'desc' : 'asc'
}

async function quickAdjustFavor(favor, delta) {
  const newValue = favor.favorValue + delta
  if (newValue < -100 || newValue > 100) {
    alert('好感度值必须在 -100 到 100 之间')
    return
  }
  
  if (!confirm(`确定要将 ${favor.npcName} 对 ${favor.playerName} 的好感度从 ${favor.favorValue} 调整为 ${newValue} (${delta > 0 ? '+' : ''}${delta})？`)) {
    return
  }
  
  const result = await npcAPI.adjustFavor(
    favor.npcId,
    favor.playerId,
    newValue,
    `快速调整${delta > 0 ? '增加' : '减少'}${Math.abs(delta)}`,
    null,
    'DM'
  )
  
  if (result?.success) {
    favor.favorValue = newValue
    favor.favorLevel = result.favorLevel
    await loadAdjustmentHistory()
  } else {
    alert(result?.message || '调整失败')
  }
}

async function directAdjustFavor(favor, event) {
  let newValue = parseInt(event.target.value)
  if (isNaN(newValue)) {
    alert('请输入有效的数值')
    event.target.value = favor.favorValue
    return
  }
  if (newValue < -100) newValue = -100
  if (newValue > 100) newValue = 100
  
  if (newValue === favor.favorValue) return
  
  if (!confirm(`确定要将 ${favor.npcName} 对 ${favor.playerName} 的好感度从 ${favor.favorValue} 调整为 ${newValue}？`)) {
    event.target.value = favor.favorValue
    return
  }
  
  const result = await npcAPI.adjustFavor(
    favor.npcId,
    favor.playerId,
    newValue,
    `直接设置为${newValue}`,
    null,
    'DM'
  )
  
  if (result?.success) {
    favor.favorValue = newValue
    favor.favorLevel = result.favorLevel
    await loadAdjustmentHistory()
  } else {
    alert(result?.message || '调整失败')
    event.target.value = favor.favorValue
  }
}

function openAdjustModal(favor = null) {
  adjustForm.value = favor ? {
    npcId: favor.npcId,
    playerId: favor.playerId,
    newValue: favor.favorValue,
    oldValue: favor.favorValue,
    reasonType: '',
    reason: ''
  } : {
    npcId: '',
    playerId: '',
    newValue: 0,
    oldValue: null,
    reasonType: '',
    reason: ''
  }
  showAdjustModal.value = true
}

async function confirmAdjustFavor() {
  if (!canAdjust.value) {
    alert('请填写必填信息：NPC、玩家和调整原因')
    return
  }
  const fullReason = adjustForm.value.reasonType
    ? `${adjustForm.value.reasonType}：${adjustForm.value.reason}`
    : adjustForm.value.reason
  const result = await npcAPI.adjustFavor(
    parseInt(adjustForm.value.npcId),
    parseInt(adjustForm.value.playerId),
    parseInt(adjustForm.value.newValue),
    fullReason,
    null,
    'DM'
  )
  if (result?.success) {
    alert(`好感度调整成功！\n${result.oldValue} → ${result.newValue} (${result.changeAmount > 0 ? '+' : ''}${result.changeAmount})\n好感度等级：${result.favorLevel}`)
    showAdjustModal.value = false
    await loadFavors()
    await loadAdjustmentHistory()
  } else {
    alert(result?.message || '好感度调整失败')
  }
}

function formatDate(dateStr) {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return date.toLocaleString('zh-CN', {
    year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit'
  })
}

function getFavorLevel(favorValue) {
  if (favorValue <= -60) return '敌视'
  if (favorValue <= -20) return '冷漠'
  if (favorValue <= 20) return '中立'
  if (favorValue <= 60) return '友善'
  return '亲近'
}

function getFavorColor(favorValue) {
  if (favorValue <= -60) return '#ef4444'
  if (favorValue <= -20) return '#f59e0b'
  if (favorValue <= 20) return '#6b7280'
  if (favorValue <= 60) return '#3b82f6'
  return '#22c55e'
}

function getStatusClass(status) {
  switch (status) {
    case '正常': return 'bg-green-900/50 text-green-400'
    case '虚弱': return 'bg-amber-900/50 text-amber-300'
    case '受伤': return 'bg-yellow-900/50 text-yellow-400'
    case '死亡': return 'bg-red-900/50 text-red-400'
    case '失踪': return 'bg-slate-600 text-slate-400'
    case '被捕': return 'bg-purple-900/50 text-purple-400'
    default: return 'bg-slate-600 text-slate-400'
  }
}

async function loadNpcInventory(npcId) {
  npcInventory.value = []
  npcSurvival.value = null
  npcConsumptionHistory.value = []
  if (!npcId) return
  const data = await npcAPI.getNpcInventory(npcId)
  if (data?.success) {
    npcInventory.value = data.inventory || []
    npcSurvival.value = data.survival || null
    npcConsumptionHistory.value = data.consumptionHistory || []
  }
}

async function onInventoryQty(item, event) {
  if (!selectedNpc.value) return
  const quantity = Math.max(0, Math.floor(Number(event.target.value) || 0))
  const result = await npcAPI.setNpcInventoryItem(selectedNpc.value.id, item.itemType, item.itemId, quantity)
  if (result?.success) {
    npcInventory.value = result.inventory || []
    npcSurvival.value = result.survival || null
  } else {
    alert(result?.message || '更新失败')
    await loadNpcInventory(selectedNpc.value.id)
  }
}

async function addInventoryItem() {
  if (!selectedNpc.value) return
  const qty = Math.max(1, Math.floor(Number(inventoryAdd.value.quantity) || 1))
  const existing = npcInventory.value.find(i => i.itemType === inventoryAdd.value.itemType && Number(i.itemId) === Number(inventoryAdd.value.itemId))
  const next = (existing?.quantity || 0) + qty
  const result = await npcAPI.setNpcInventoryItem(
    selectedNpc.value.id,
    inventoryAdd.value.itemType,
    inventoryAdd.value.itemId,
    next
  )
  if (result?.success) {
    npcInventory.value = result.inventory || []
    npcSurvival.value = result.survival || null
  } else {
    alert(result?.message || '加入失败')
  }
}

async function seedNpcInventory(mode) {
  if (!selectedNpc.value) return
  if (mode === 'replace' && !confirm('将清空该NPC背包并按职业重新发放玩家职业初始物资，确定？')) {
    return
  }
  const result = await npcAPI.seedNpcInventory(selectedNpc.value.id, mode)
  if (result?.success) {
    npcInventory.value = result.inventory || []
    npcSurvival.value = result.survival || null
    alert(result.message)
  } else {
    alert(result?.message || '操作失败')
  }
}

async function loadRecognitionPlayers(npcId) {
  recognitionPlayers.value = []
  if (npcId) {
    const data = await npcAPI.getRecognizedPlayers(npcId)
    if (data) recognitionPlayers.value = data
  }
}

function openAddRecognitionModal(npcId) {
  selectedRecognitionNpc.value = npcs.value.find(n => n.id === npcId)
  addRecognitionForm.value = {
    npcId: npcId,
    playerId: ''
  }
  showAddRecognitionModal.value = true
}

async function confirmAddRecognition() {
  if (!addRecognitionForm.value.playerId) {
    alert('请选择要建立认识关系的玩家')
    return
  }
  
  const npc = npcs.value.find(n => n.id === addRecognitionForm.value.npcId)
  const player = players.value.find(p => p.id == addRecognitionForm.value.playerId)
  
  if (!confirm(`确定要让 ${npc?.name} 认识 ${player?.name} 吗？`)) {
    return
  }
  
  const result = await npcAPI.createRecognition(
    addRecognitionForm.value.npcId,
    parseInt(addRecognitionForm.value.playerId)
  )
  
  if (result?.success) {
    alert('认识关系建立成功')
    showAddRecognitionModal.value = false
    await loadRecognitionPlayers(addRecognitionForm.value.npcId)
    await loadFavors()
  } else {
    alert(result?.message || '建立认识关系失败')
  }
}

async function removeRecognition(recognition) {
  const npc = npcs.value.find(n => n.id === recognition.npcId)
  if (!confirm(`确定要解除 ${npc?.name} 与玩家ID ${recognition.playerId} 的认识关系吗？`)) {
    return
  }
  
  const result = await npcAPI.deleteRecognition(recognition.npcId, recognition.playerId)
  
  if (result?.success) {
    alert('认识关系已解除')
    await loadRecognitionPlayers(recognition.npcId)
    await loadFavors()
  } else {
    alert(result?.message || '解除认识关系失败')
  }
}

async function loadClues() {
  const data = await specialClueAPI.getAll()
  if (data) clues.value = data
}

function selectClue(clue) {
  selectedClue.value = clue
  loadClueLogs()
}

async function loadClueLogs() {
  if (!selectedClue.value) return
  const data = await specialClueAPI.getLogs(null, selectedClue.value.id)
  if (data) clueLogs.value = data
}

function closeClueModal() {
  showCreateClueModal.value = false
  showEditClueModal.value = false
  clueForm.value = {
    clueCode: '',
    description: '',
    keywords: '',
    content: '',
    matchMode: 'EXACT',
    probabilityWeight: 50,
    cooldownMinutes: 5,
    priority: 0,
    isActive: true
  }
}

async function saveClue() {
  if (!clueForm.value.keywords || !clueForm.value.content) {
    alert('请填写必填字段：唤醒关键词和线索内容')
    return
  }
  if (showEditClueModal.value) {
    const result = await specialClueAPI.update(selectedClue.value.id, clueForm.value)
    if (result?.success) {
      alert('线索更新成功')
      closeClueModal()
      await loadClues()
    } else {
      alert(result?.message || '更新失败')
    }
  } else {
    const result = await specialClueAPI.create(clueForm.value)
    if (result?.success) {
      alert('线索创建成功')
      closeClueModal()
      await loadClues()
    } else {
      alert(result?.message || '创建失败')
    }
  }
}

async function toggleClueActive() {
  if (!selectedClue.value) return
  const result = await specialClueAPI.update(selectedClue.value.id, {
    isActive: !selectedClue.value.isActive
  })
  if (result?.success) {
    selectedClue.value.isActive = !selectedClue.value.isActive
    await loadClues()
  } else {
    alert(result?.message || '操作失败')
  }
}

async function confirmDeleteClue() {
  if (!selectedClue.value) return
  if (!confirm(`确定要删除线索 "${selectedClue.value.clueCode}" 吗？此操作不可恢复。`)) return
  const result = await specialClueAPI.delete(selectedClue.value.id)
  if (result?.success) {
    alert('线索删除成功')
    selectedClue.value = null
    clueLogs.value = []
    await loadClues()
  } else {
    alert(result?.message || '删除失败')
  }
}

async function exportClues() {
  const data = await specialClueAPI.export()
  if (data) {
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `clues_export_${new Date().toISOString().split('T')[0]}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  }
}

async function doImport() {
  if (!importData.value) {
    alert('请先粘贴要导入的JSON数据')
    return
  }
  try {
    JSON.parse(importData.value)
  } catch {
    alert('无效的JSON数据格式')
    return
  }
  const result = await specialClueAPI.import(JSON.parse(importData.value))
  if (result?.success) {
    alert(`成功导入 ${result.count} 条线索`)
    showImportModal.value = false
    importData.value = ''
    await loadClues()
  } else {
    alert(result?.message || '导入失败')
  }
}

function getAttitudeClass(attitude) {
  switch (attitude) {
    case '喜好': return 'bg-green-900/50 text-green-400'
    case '厌恶': return 'bg-red-900/50 text-red-400'
    case '忽视': return 'bg-slate-600 text-slate-400'
    default: return 'bg-slate-600 text-slate-400'
  }
}

function getItemList(itemType) {
  return itemCatalog[itemType] || []
}

async function handleFavorRangeChange(favor, event) {
  const newValue = parseInt(event.target.value)
  if (newValue === favor.favorValue) return
  
  if (!confirm(`确定要将 ${favor.playerName} 对该NPC的好感度从 ${favor.favorValue} 调整为 ${newValue}？`)) {
    event.target.value = favor.favorValue
    return
  }
  
  const result = await npcAPI.adjustFavor(
    favor.npcId,
    favor.playerId,
    newValue,
    `拖动滑块调整为${newValue}`,
    null,
    'DM'
  )
  
  if (result?.success) {
    favor.favorValue = newValue
    favor.favorLevel = result.favorLevel
    await loadAdjustmentHistory()
  } else {
    alert(result?.message || '调整失败')
    event.target.value = favor.favorValue
  }
}

async function handleFavorInputChange(favor, event) {
  let newValue = parseInt(event.target.value)
  if (isNaN(newValue)) {
    alert('请输入有效的数值')
    event.target.value = favor.favorValue
    return
  }
  if (newValue < -100) newValue = -100
  if (newValue > 100) newValue = 100
  
  if (newValue === favor.favorValue) return
  
  if (!confirm(`确定要将 ${favor.playerName} 对该NPC的好感度从 ${favor.favorValue} 调整为 ${newValue}？`)) {
    event.target.value = favor.favorValue
    return
  }
  
  const result = await npcAPI.adjustFavor(
    favor.npcId,
    favor.playerId,
    newValue,
    `直接输入设置为${newValue}`,
    null,
    'DM'
  )
  
  if (result?.success) {
    favor.favorValue = newValue
    favor.favorLevel = result.favorLevel
    await loadAdjustmentHistory()
  } else {
    alert(result?.message || '调整失败')
    event.target.value = favor.favorValue
  }
}

onMounted(() => {
  refreshAll()
  loadClues()
})
</script>