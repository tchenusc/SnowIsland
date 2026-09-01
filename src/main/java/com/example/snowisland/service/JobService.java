package com.example.snowisland.service;

import com.example.snowisland.entity.Job;
import com.example.snowisland.entity.JobInitialItems;
import com.example.snowisland.entity.TradeItem.ItemType;
import com.example.snowisland.repository.JobInitialItemsRepository;
import com.example.snowisland.repository.JobRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class JobService {

    @Autowired
    private JobRepository jobRepository;

    @Autowired
    private JobInitialItemsRepository jobInitialItemsRepository;

    private static final Map<String, Map<Integer, String>> ITEM_NAMES = new HashMap<>();

    static {
        Map<Integer, String> itemNames = new HashMap<>();
        itemNames.put(1, "医疗资源");
        itemNames.put(2, "手电筒");
        itemNames.put(3, "手铐");
        itemNames.put(4, "哨子");
        itemNames.put(5, "防弹衣");
        itemNames.put(6, "复合盾");
        itemNames.put(7, "信号枪");
        itemNames.put(8, "维修工具包");
        itemNames.put(9, "协议书");
        itemNames.put(10, "朗姆酒");
        itemNames.put(11, "草药");
        itemNames.put(12, "渔网");
        itemNames.put(13, "蜡烛");
        itemNames.put(14, "医用酒精");
        itemNames.put(15, "火柴");
        itemNames.put(16, "铅笔");
        itemNames.put(17, "破损海图");
        itemNames.put(18, "面包");
        itemNames.put(19, "矿场仓库钥匙");
        itemNames.put(20, "燃料仓库钥匙");
        itemNames.put(21, "镇武库钥匙");
        itemNames.put(22, "码头集换站钥匙");
        itemNames.put(23, "反叛者基地钥匙");
        itemNames.put(24, "方舟钥匙");
        itemNames.put(25, "火把");
        ITEM_NAMES.put("item", itemNames);

        Map<Integer, String> weaponNames = new HashMap<>();
        weaponNames.put(1, "制式手枪");
        weaponNames.put(2, "猎枪");
        weaponNames.put(3, "警棍");
        weaponNames.put(4, "刺刀");
        weaponNames.put(5, "水手刀");
        weaponNames.put(6, "鱼叉/矛");
        weaponNames.put(7, "猎弓");
        weaponNames.put(8, "十字镐");
        weaponNames.put(9, "斧头");
        weaponNames.put(10, "电锯");
        weaponNames.put(11, "手术刀");
        weaponNames.put(12, "炸药");
        ITEM_NAMES.put("weapon", weaponNames);

        Map<Integer, String> ammoNames = new HashMap<>();
        ammoNames.put(1, "手枪弹");
        ammoNames.put(2, "猎枪弹");
        ammoNames.put(3, "信号弹");
        ammoNames.put(4, "箭矢");
        ITEM_NAMES.put("ammo", ammoNames);

        Map<Integer, String> materialNames = new HashMap<>();
        materialNames.put(1, "金属制品");
        materialNames.put(2, "木材");
        materialNames.put(3, "绳索");
        materialNames.put(4, "木板");
        materialNames.put(5, "食物");
        materialNames.put(6, "沥青");
        materialNames.put(7, "石料");
        materialNames.put(8, "燃料");
        materialNames.put(9, "帆布");
        materialNames.put(10, "发动机");
        materialNames.put(11, "螺旋桨");
        materialNames.put(12, "发电机");
        ITEM_NAMES.put("material", materialNames);
    }

    public List<Job> getAllJobs() {
        List<Job> visible = new ArrayList<>();
        for (Job job : jobRepository.findAll()) {
            if (!Boolean.TRUE.equals(job.getHidden())) {
                visible.add(job);
            }
        }
        return visible;
    }

    public List<Job> getAllJobsIncludingHidden() {
        return jobRepository.findAll();
    }

    public Optional<Job> getJobById(Integer id) {
        return jobRepository.findById(id);
    }

    public Job saveJob(Job job) {
        return jobRepository.save(job);
    }

    @Transactional
    public void deleteJob(Integer id) {
        jobInitialItemsRepository.deleteByJobId(id);
        jobRepository.deleteById(id);
    }

    public List<JobInitialItems> getInitialItemsByJobId(Integer jobId) {
        return jobInitialItemsRepository.findByJobId(jobId);
    }

    @Transactional
    public void saveInitialItems(Integer jobId, List<JobInitialItems> items) {
        jobInitialItemsRepository.deleteByJobId(jobId);
        items.forEach(item -> item.setJobId(jobId));
        jobInitialItemsRepository.saveAll(items);
    }

    public Map<String, Object> getJobWithInitialItems(Integer jobId) {
        Map<String, Object> result = new HashMap<>();

        Optional<Job> jobOpt = jobRepository.findById(jobId);
        if (!jobOpt.isPresent()) {
            result.put("success", false);
            result.put("message", "职业不存在");
            return result;
        }

        Job job = jobOpt.get();
        result.put("success", true);
        result.put("job", job);

        List<JobInitialItems> initialItems = jobInitialItemsRepository.findByJobIdOrderByItemType(jobId);
        List<Map<String, Object>> itemsWithInfo = new ArrayList<>();

        for (JobInitialItems item : initialItems) {
            Map<String, Object> itemInfo = new HashMap<>();
            itemInfo.put("id", item.getId());
            itemInfo.put("itemType", item.getItemType().name());
            itemInfo.put("itemId", item.getItemId());
            itemInfo.put("quantity", item.getQuantity());
            itemInfo.put("unit", item.getUnit());

            String name = getItemName(item.getItemType(), item.getItemId());
            itemInfo.put("name", name);

            itemsWithInfo.add(itemInfo);
        }

        result.put("initialItems", itemsWithInfo);
        return result;
    }

    private String getItemName(ItemType itemType, Integer itemId) {
        Map<Integer, String> names = ITEM_NAMES.get(itemType.name().toLowerCase());
        if (names != null && itemId != null) {
            String name = names.get(itemId);
            if (name != null) {
                return name;
            }
        }
        return "未知物品";
    }

    public List<Map<String, Object>> getAllJobsWithInitialItems() {
        List<Job> jobs = getAllJobs();
        List<Map<String, Object>> result = new ArrayList<>();

        for (Job job : jobs) {
            Map<String, Object> jobInfo = new HashMap<>();
            jobInfo.put("id", job.getId());
            jobInfo.put("name", job.getName());
            jobInfo.put("skills", job.getSkills());

            List<JobInitialItems> initialItems = jobInitialItemsRepository.findByJobId(job.getId());
            List<Map<String, Object>> itemsWithInfo = new ArrayList<>();

            for (JobInitialItems item : initialItems) {
                Map<String, Object> itemInfo = new HashMap<>();
                itemInfo.put("itemType", item.getItemType().name());
                itemInfo.put("itemId", item.getItemId());
                itemInfo.put("quantity", item.getQuantity());
                itemInfo.put("unit", item.getUnit());
                itemInfo.put("name", getItemName(item.getItemType(), item.getItemId()));
                itemsWithInfo.add(itemInfo);
            }

            jobInfo.put("initialItems", itemsWithInfo);
            result.add(jobInfo);
        }

        return result;
    }
}