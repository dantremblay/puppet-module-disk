# == Class: disk
#
# Module to manage disk
#
class disk (
  $quotas = undef,
) {

  if $quotas != undef {
    validate_hash($quotas)

    create_resources('disk::quota', $quotas)
  }
}
