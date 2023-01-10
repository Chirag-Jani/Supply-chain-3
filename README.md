# Flow

1. deploy the contract (the deployer will be the 'Manager' of the contract)

2. add members (without adding, no shipper, transporter, or consigner will be allowed):

- manager itself cannot be a member (it can only manage)
- at least 3 members need to be added
  - 1 shipper
  - 1 transporter
  - 1 consigner

3. create a cargo:

- only shipper can create a cargo
- remember to switch the account to shipper's address
- add valid transporter and consigner
- only added members will be allowed to sign the cargo later
- even if another address is added as a transporter or consigner, it will not be able to sign the cargo

4. sign the cargo at the transporter

- transporter which is trying to sign should be added while creating the cargo

5. sign the cargo at the consigner (with valid payments as the price of the packet is added while creating the cargo)

- the amount will be transferred to the shipper's address
- Consigner will not be able to sign if the packet is not first signed by the valid transporter

6. At any point in time, one can see the status of the cargo.

- id of packet
- info. of packet
- price
- shipper
- transporter
- consigner
- state of the packet
- time when it was created
- At which end it was last signed by (Shipper, Transporter, or Consigner)
- Address of the member who signed the cargo
- Get the member details from the address
  - details like, Name, Address, and Type of the signer
