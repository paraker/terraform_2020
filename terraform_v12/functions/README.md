# [Functions](https://www.terraform.io/docs/configuration/functions.html)
There are a range of predefined functions from Hashicorp.<br>
We will be using the [cidrsubnet](https://www.terraform.io/docs/configuration/functions/cidrsubnet.html) function

`cidrsubnet` calculates a subnet address within given IP network address prefix.

    cidrsubnet(prefix, newbits, netnum)
    
* `prefix` must be given in CIDR notation, as defined in RFC 4632 section 3.1.
* `newbits` is the number of additional bits with which to extend the prefix. For example, if given a prefix ending in `/16` and a `newbits` value of `4`, the resulting subnet address will have length `/20`.
* `netnum` is a whole number that can be represented as a binary integer with no more than `newbits` binary digits, which will be used to populate the additional bits added to the prefix.
    
Examples:
    
    > cidrsubnet("172.16.0.0/12", 4, 2)
    172.18.0.0/16
    > cidrsubnet("10.1.2.0/24", 4, 15)
    10.1.2.240/28