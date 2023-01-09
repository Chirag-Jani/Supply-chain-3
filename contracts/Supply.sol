// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Supply {
    // manager == deployer
    address manager;

    // packet struct
    struct Packet {
        uint256 id;
        uint256 timestamp;
        uint256 price;
        string packetInfo;
        PacketState state;
        Entities lastUpdateBy;
        address payable shipper;
        address transporter;
        address consigner;
    }

    // Acting Entities
    enum Entities {
        Shipper,
        Transporter,
        Consigner
    }

    // packet state
    enum PacketState {
        Packed,
        Dispatched,
        Delivered
    }

    // Member struct
    struct Member {
        string Name;
        address Address;
        Entities Type;
    }

    // alll the members
    Member[] members;

    // to manage indexes
    uint256 curMemId;

    // to get member info from address
    mapping(address => Member) getMember;

    // to check the authority
    mapping(address => bool) isShipper;
    mapping(address => bool) isTransporter;
    mapping(address => bool) isConsigner;

    // all the packets
    Packet[] allPackets;

    // to manage packet indexes
    uint256 curPktId;

    // to get packet info from id
    mapping(uint256 => Packet) packet;

    // setting manager
    constructor() {
        manager = msg.sender;
    }

    // adding new members
    function addMember(
        string memory _memberName,
        address _memberAddress,
        Entities _memberType
    ) public {
        require(_memberAddress != address(0), "Zero address not allowed");
        require(msg.sender == manager, "Only Manager can add members");
        require(
            isShipper[_memberAddress] == false &&
                isTransporter[_memberAddress] == false &&
                isConsigner[_memberAddress] == false,
            "Member exist"
        );
        members[curMemId] = Member(_memberName, _memberAddress, _memberType);
        curMemId++;

        // adding to mapping
        if (_memberType == Entities.Shipper) {
            isShipper[_memberAddress] = true;
        } else if (_memberType == Entities.Transporter) {
            isTransporter[_memberAddress] = true;
        } else {
            isConsigner[_memberAddress] = true;
        }
    }

    // creating a cargo
    function createCargo(
        uint256 _price,
        string memory _packetInfo,
        address _shipper,
        address _tansporter,
        address _consigner
    ) public {
        // not zero addresses
        require(
            _shipper != address(0) ||
                _tansporter != address(0) ||
                _consigner != address(0),
            "Zero address not allowed"
        );

        // msg.sender needs to be a shipper entity
        require(
            getMember[msg.sender].Type == Entities.Shipper,
            "Only Shipper can create cargo"
        );

        // check shipper
        require(isShipper[_shipper] == true, "Shipper not allowed");

        // check tansporter
        require(isTransporter[_tansporter] == true, "Transporter not allowed");

        // check consigner
        require(isConsigner[_consigner] == true, "Consigner not allowed");

        // adding packet
        allPackets.push(
            Packet(
                curPktId,
                block.timestamp,
                _price,
                _packetInfo,
                PacketState.Packed,
                Entities.Shipper,
                payable(_shipper),
                _tansporter,
                _consigner
            )
        );

        // adding to mapping
        packet[curPktId] = allPackets[curPktId];

        // incrementing index for the next one
        curPktId++;
    }

    // signing at transport
    function signTransport(uint256 _id) public {
        // msg.sender needs to be a transport entity
        require(
            getMember[msg.sender].Type == Entities.Transporter,
            "Only Transporter can dispatch cargo"
        );

        // you are not authorized to sign the tansport
        require(
            packet[_id].transporter == msg.sender,
            "you are not authorized to sign the tansport"
        );

        // checking packet state
        require(
            packet[_id].state == PacketState.Packed,
            "Item needs to be in Packed State"
        );

        // updating packet info
        packet[_id].state = PacketState.Dispatched;
        packet[_id].lastUpdateBy = Entities.Transporter;
    }

    // signing at consigner
    function signDelivered(uint256 _id) public payable {
        // msg.sender needs to be a consigner entity
        require(
            getMember[msg.sender].Type == Entities.Consigner,
            "Only Consigner can recieve cargo"
        );

        // you are not authorized to sign the delivery
        require(
            packet[_id].consigner == msg.sender,
            "you are not authorized to sign the delivery"
        );

        // checking packet state
        require(
            packet[_id].state == PacketState.Dispatched,
            "Item needs to be in Dispatched State"
        );

        // need to do payments while delivery
        (bool success, ) = packet[_id].shipper.call{value: packet[_id].price}(
            ""
        );
        require(success == true, "Fund transfer error");

        // updating packet info
        packet[_id].state = PacketState.Delivered;
        packet[_id].lastUpdateBy = Entities.Consigner;
    }

    // getting packet info
    function getPacket(uint256 _id) public view returns (Packet memory) {
        return packet[_id];
    }
}

// 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB
// 0x583031D1113aD414F02576BD6afaBfb302140225
// 0xdD870fA1b7C4700F2BD7f44238821C26f7392148
