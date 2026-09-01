package com.example.snowisland.service;

import com.example.snowisland.entity.Location;
import com.example.snowisland.entity.LocationFacility;
import com.example.snowisland.entity.LocationNpc;
import com.example.snowisland.repository.LocationFacilityRepository;
import com.example.snowisland.repository.LocationNpcRepository;
import com.example.snowisland.repository.LocationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class LocationService {

    @Autowired
    private LocationRepository locationRepository;

    @Autowired
    private LocationFacilityRepository facilityRepository;

    @Autowired
    private LocationNpcRepository npcRepository;

    public List<Map<String, Object>> getAllLocations() {
        List<Location> locations = locationRepository.findAllByOrderByOrderNumberAsc();
        return locations.stream().map(this::toDetailMap).collect(Collectors.toList());
    }

    public List<Map<String, Object>> getLocationsByArea(String area) {
        List<Location> locations = locationRepository.findByAreaOrderByOrderNumberAsc(area);
        return locations.stream().map(this::toDetailMap).collect(Collectors.toList());
    }

    public Map<String, Object> getLocationById(Integer id) {
        Optional<Location> optional = locationRepository.findById(id);
        if (!optional.isPresent()) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "地点不存在");
            return result;
        }
        return toDetailMap(optional.get());
    }

    @Transactional
    public Map<String, Object> createLocation(Location location, List<LocationFacility> facilities, List<LocationNpc> npcs) {
        Location saved = locationRepository.save(location);

        if (facilities != null) {
            for (LocationFacility f : facilities) {
                f.setLocationId(saved.getId());
                facilityRepository.save(f);
            }
        }
        if (npcs != null) {
            for (LocationNpc n : npcs) {
                n.setLocationId(saved.getId());
                npcRepository.save(n);
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "地点创建成功");
        result.put("data", toDetailMap(saved));
        return result;
    }

    @Transactional
    public Map<String, Object> updateLocation(Integer id, Location updated, List<LocationFacility> facilities, List<LocationNpc> npcs) {
        Optional<Location> optional = locationRepository.findById(id);
        if (!optional.isPresent()) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "地点不存在");
            return result;
        }

        Location existing = optional.get();
        if (updated.getName() != null) existing.setName(updated.getName());
        if (updated.getArea() != null) existing.setArea(updated.getArea());
        if (updated.getDescription() != null) existing.setDescription(updated.getDescription());
        if (updated.getDefenseValue() != null) existing.setDefenseValue(updated.getDefenseValue());
        if (updated.getManagement() != null) existing.setManagement(updated.getManagement());
        if (updated.getOrderNumber() != null) existing.setOrderNumber(updated.getOrderNumber());

        locationRepository.save(existing);

        if (facilities != null) {
            facilityRepository.deleteByLocationId(id);
            for (LocationFacility f : facilities) {
                f.setId(null);
                f.setLocationId(id);
                facilityRepository.save(f);
            }
        }
        if (npcs != null) {
            npcRepository.deleteByLocationId(id);
            for (LocationNpc n : npcs) {
                n.setId(null);
                n.setLocationId(id);
                npcRepository.save(n);
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "地点更新成功");
        result.put("data", toDetailMap(existing));
        return result;
    }

    @Transactional
    public Map<String, Object> deleteLocation(Integer id) {
        if (!locationRepository.existsById(id)) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "地点不存在");
            return result;
        }
        facilityRepository.deleteByLocationId(id);
        npcRepository.deleteByLocationId(id);
        locationRepository.deleteById(id);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "地点删除成功");
        return result;
    }

    private Map<String, Object> toDetailMap(Location location) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", location.getId());
        map.put("name", location.getName());
        map.put("area", location.getArea());
        map.put("description", location.getDescription());
        map.put("defenseValue", location.getDefenseValue());
        map.put("management", location.getManagement());
        map.put("orderNumber", location.getOrderNumber());

        List<LocationFacility> facilities = facilityRepository.findByLocationId(location.getId());
        List<Map<String, Object>> facilityList = new ArrayList<>();
        for (LocationFacility f : facilities) {
            Map<String, Object> fm = new LinkedHashMap<>();
            fm.put("id", f.getId());
            fm.put("name", f.getName());
            fm.put("description", f.getDescription());
            facilityList.add(fm);
        }
        map.put("facilities", facilityList);

        List<LocationNpc> npcs = npcRepository.findByLocationId(location.getId());
        List<Map<String, Object>> npcList = new ArrayList<>();
        for (LocationNpc n : npcs) {
            Map<String, Object> nm = new LinkedHashMap<>();
            nm.put("id", n.getId());
            nm.put("name", n.getName());
            nm.put("job", n.getJob());
            nm.put("status", n.getStatus());
            nm.put("gender", n.getGender() != null ? n.getGender().name() : null);
            nm.put("introduction", n.getIntroduction());
            nm.put("attitudeRuler", n.getAttitudeRuler() != null ? n.getAttitudeRuler().name() : null);
            nm.put("attitudeRebel", n.getAttitudeRebel() != null ? n.getAttitudeRebel().name() : null);
            nm.put("attitudeAdventurer", n.getAttitudeAdventurer() != null ? n.getAttitudeAdventurer().name() : null);
            nm.put("attitudeScourge", n.getAttitudeScourge() != null ? n.getAttitudeScourge().name() : null);
            npcList.add(nm);
        }
        map.put("npcs", npcList);

        return map;
    }
}
