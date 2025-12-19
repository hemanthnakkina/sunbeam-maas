resource "maas_tag" "tag" {
  for_each    = var.tags
  name        = each.key
  machines    = each.value.machines
  definition  = try(each.value.definition, null)
  kernel_opts = try(each.value.kernel_opts, null)
}
