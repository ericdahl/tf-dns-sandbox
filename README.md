# tf-dns-sandbox

Demos of DNS architectures in AWS

- Centralized DNS
    - Private R53 zones in one VPC
    - Other VPCs get zones shared to them
    - custom rules route to a special DNS server (simulating on-prem, or similar)