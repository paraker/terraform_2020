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
 
## Dynamic blocks - where expressions can't be used
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

    resource "aws_security_group" "example" {
      name = "example" # can use expressions here
    
      dynamic "ingress" {
        for_each = var.service_ports
        content {
          from_port = ingress.value
          to_port   = ingress.value
          protocol  = "tcp"
        }
      }
    }
A dynamic block acts much like a for expression, but produces nested blocks instead of a complex typed value.<br>
* The label of the dynamic block (`"ingress"` in the example above) specifies what kind of nested block to generate.
* The `for_each` argument provides the complex value to iterate over.
* The `iterator` argument sets the name of a temporary variable that represents the current element of the complex value. If omitted, the name of the variable defaults to the label of the `dynamic` block (`"ingress"` in the example above). 
* The nested `content` block defines the body of each generated block.

 