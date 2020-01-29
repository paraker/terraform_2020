# [Expressions](https://www.terraform.io/docs/configuration/expressions.html)
## TF Block Basics
The syntax of the Terraform language consists of only a few basic elements:
    
    <BLOCK TYPE> "<BLOCK LABEL>" "<BLOCK LABEL>" {
      # Block body
      <IDENTIFIER> = <EXPRESSION> # Argument
    }
Expressions represent a value, either literally or by referencing and combining other values.<br>
We have been setting heaps of expressions all the time throughout the code, we just haven't put a name to it.<br> 
In these examples we will be looking at a more advanced use of expressions, not just static typing or interpolation.

## Multiple iterations in one block
By default, a resource block configures one real infrastructure object.<br>
However, sometimes you want to manage several similar objects, such as a fixed pool of compute instances.<br>
Terraform has two ways to do this: `count` and `for_each`. <br>
I assume this can be used in the body of `resource`, `data`, `provider`, and `provisioner` blocks. 
### for_each
The `for_each` meta-argument accepts a map or a set of strings, and creates an instance for each item in that map or set.

    resource "azurerm_resource_group" "rg" {
      for_each = {
        a_group = "eastus"
        another_group = "westus2"
      }
      name     = each.key
      location = each.value
    }
`each.key` — The map key (or set member) corresponding to this instance.<br>
`each.value` — The map value corresponding to this instance. (If a set was provided, this is the same as each.key.)

When `for_each` is set, Terraform distinguishes between the resource block itself and the multiple resource instances associated with it.<br>
Instances are identified by a map key (or set member) from the value provided to `for_each`.

    <TYPE>.<NAME> (for example, azurerm_resource_group.rg) refers to the resource block.
    <TYPE>.<NAME>[<KEY>] (for example, azurerm_resource_group.rg["a_group"],azurerm_resource_group.rg["another_group"], etc.) refers to individual instances.
 
## Dynamic blocks with for_each - where expressions can't be used
Within top-level block constructs like resources, expressions can usually be used only when assigning a value to
an argument using the `name = expression` form. This covers many uses, but some resource types include repeatable
nested blocks in their arguments, which do not accept expressions.

    resource "aws_security_group" "example" {
      name = "example" # can use expressions here
    
      ingress {
        # but the "ingress" block is always a literal block
      }
    }

You can dynamically construct repeatable nested blocks like `ingress` using a special `dynamic` block type, which is supported inside `resource`, `data`, `provider`, and `provisioner` blocks:

    # List of ports that we will iterate over.
    variable "service_ports" {
      default = ["22", "80", "8080"]
    }

    # Resource block we will use a dynamic block in
    resource "aws_security_group" "tf_public_sg" {
      name        = "tf_public_sg"
      vpc_id      = aws_vpc.tf_vpc.id
    
      dynamic "ingress" {                    # Defines a dynamic block that we can iterate over
        for_each = var.service_ports         # Defines our complex variable to iterate over 
        iterator = network_ports             # Defines an iterator, i.e. a reference to our variable we can iterate over
        content {                            # Content block that will be repeated for each variable we can iterate over
          from_port   = network_ports.value  # We use the value from our iterator, this will be 22, then 80, then 8080
          to_port     = network_ports.value  # We use the value from our iterator, this will be 22, then 80, then 8080
          protocol    = "tcp"
          cidr_blocks = [var.accessip]
        }
       }
     }
A dynamic block acts much like a for expression, but produces nested blocks instead of a complex typed value.<br>
* The label of the dynamic block (`"ingress"` in the example above) specifies what kind of nested block to generate.
* The `for_each` argument provides the complex value to iterate over.
* The `iterator` argument sets the name of a temporary variable that represents the current element of the complex value. If omitted, the name of the variable defaults to the label of the `dynamic` block (`"ingress"` in the example above). 
* The nested `content` block defines the body of each generated block.

 The iterator object (ingress in the example above) has two attributes:

* `key` is the map key or list element index for the current element. If the `for_each` expression produces a set value then `key` is identical to `value` and should not be used.
* `value` is the value of the current element.


## Dynamic blocks with `for` - where expressions can't be used
More advanced example. Suitable where you need to be flexible with your values in each iteration.<br> 

Define our security group

    # More advanced looping over a list of maps
    variable "service_ports_list_of_maps" {
      default = [
        {
          from_port = "22",
          to_port   = "22"
        },
        {
          from_port = "80",
          to_port   = "80"
        }
      ]
    }

Define our security group

    resource "aws_security_group" "tf_public_sg_list_of_maps" {
      name        = "tf_public_sg_list_of_maps"
      description = "Used for access to the public instances"
      vpc_id      = aws_vpc.tf_vpc.id
    
      dynamic "ingress" {  # Defines a dynamic block that we can iterate over
        for_each = [ for port in var.service_ports_list_of_maps: {  # for loop is initiated, "port" is set to each respective element in the list of maps
          from_port = port.from_port
          to_port = port.to_port
        }]  # the [] indicate that a tuple will be generated.
        iterator = network_ports  # Defines an iterator, i.e. a reference to our variable we can iterate over
    
        content {
          from_port   = network_ports.value.from_port  # Grabs the from_port value from our iterator. Will be 22, then 80
          to_port     = network_ports.value.to_port    # Grabs the to_port value from our iterator. Will be 22, then 80
          protocol    = "tcp"
          cidr_blocks = [var.accessip]
        }
      }
    }

And output

    output "ingress_port_mapping" {
      value = {
        for ingress in aws_security_group.tf_public_sg_list_of_maps.ingress:  # for loop is initiated, "ingress" is set to each respective element of the dynamic block "ingress"
        format("From %d", ingress.from_port) => format("To %d", ingress.to_port)  # outputs the values of ingress' ports, will first be 22,22 then 80,80
      }
    }

This is the output

    ingress_port_mapping = {
      "From 22" = "To 22"
      "From 80" = "To 80"
    }
