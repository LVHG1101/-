package com.example.secondhand.service;

import com.example.secondhand.entity.Address;
import com.example.secondhand.repository.AddressRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AddressService {

    @Autowired
    private AddressRepository addressRepository;

    public List<Address> list(Long userId) {
        return addressRepository.findByUserIdOrderByIdDesc(userId);
    }

    @Transactional
    public Address save(Long userId, Address incoming) {
        if (incoming.getName() == null || incoming.getName().isBlank()) {
            throw new IllegalArgumentException("收货人不能为空");
        }
        if (incoming.getPhone() == null || incoming.getPhone().isBlank()) {
            throw new IllegalArgumentException("手机号不能为空");
        }
        Address target;
        if (incoming.getId() == null) {
            target = new Address();
        } else {
            target = addressRepository.findById(incoming.getId())
                    .orElseThrow(() -> new IllegalArgumentException("地址不存在"));
            if (!target.getUserId().equals(userId)) {
                throw new IllegalArgumentException("无权操作该地址");
            }
        }
        target.setUserId(userId);
        target.setName(incoming.getName());
        target.setPhone(incoming.getPhone());
        target.setProvince(incoming.getProvince() == null ? "" : incoming.getProvince());
        target.setCity(incoming.getCity() == null ? "" : incoming.getCity());
        target.setDistrict(incoming.getDistrict() == null ? "" : incoming.getDistrict());
        target.setDetail(incoming.getDetail() == null ? "" : incoming.getDetail());
        target.setIsDefault(Boolean.TRUE.equals(incoming.getIsDefault()));
        if (Boolean.TRUE.equals(target.getIsDefault())) {
            clearDefault(userId);
        }
        return addressRepository.save(target);
    }

    @Transactional
    public void setDefault(Long userId, Long addressId) {
        Address address = addressRepository.findById(addressId)
                .orElseThrow(() -> new IllegalArgumentException("地址不存在"));
        if (!address.getUserId().equals(userId)) {
            throw new IllegalArgumentException("无权操作该地址");
        }
        clearDefault(userId);
        address.setIsDefault(true);
        addressRepository.save(address);
    }

    @Transactional
    public void delete(Long userId, Long addressId) {
        Address address = addressRepository.findById(addressId)
                .orElseThrow(() -> new IllegalArgumentException("地址不存在"));
        if (!address.getUserId().equals(userId)) {
            throw new IllegalArgumentException("无权操作该地址");
        }
        addressRepository.delete(address);
    }

    private void clearDefault(Long userId) {
        for (Address a : addressRepository.findByUserIdOrderByIdDesc(userId)) {
            if (Boolean.TRUE.equals(a.getIsDefault())) {
                a.setIsDefault(false);
                addressRepository.save(a);
            }
        }
    }
}
