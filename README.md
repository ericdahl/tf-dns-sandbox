# tf-dns-sandbox

Demos of DNS architectures in AWS

- Centralized DNS
    - Private R53 zones in one VPC (10.1.0.0/16)
    - Other VPCs (10.2.0.0/16) get zones shared to them
    - custom rules route to a special DNS server (simulating on-prem, or similar)
      - note: other VPCs can resolve this "onprem" DNS without any VPC Peering, TGW or similar
  

```
terraform apply

ssh ec2-user@<jumphost for VPC 2>

# resolves address across VPC with shared R53 rules
[ec2-user@ip-10-2-1-57 ~]$ host a.onprem
a.onprem has address 1.2.3.4
```