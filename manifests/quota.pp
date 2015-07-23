# == Define: disk::quota
#
define disk::quota (
  $ensure          = 'present',
  $type            = 'user',
  $mount_point     = 'MANDATORY',
  $block_softlimit = 0,
  $block_hardlimit = 0,
  $inode_softlimit = 0,
  $inode_hardlimit = 0,
) {

  validate_re($name, '^[A-Z,a-z,0-9]+$',
    "disk::quota::${name} can only contain letters and numerals.")

  validate_re($ensure, [ '^present$', '^absent$' ],
    "disk::quota::${name}::ensure is invalid and does not match the regex.")

  validate_re($type, [ '^user$', '^group$' ],
    "disk::quota::${name}::type is invalid and does not match the regex.")

  if $mount_point == 'MANDATORY' {
    fail("disk::quota::${name}::mount_point is MANDATORY.")
  } else {
    validate_absolute_path($mount_point)
  }

  validate_integer($block_softlimit)
  validate_integer($block_hardlimit)
  validate_integer($inode_softlimit)
  validate_integer($inode_hardlimit)

  if $type == 'user' {
    $name_switch = '-u'
  }
  if $type == 'group' {
    $name_switch = '-g'
  }

  if $ensure == 'present' {
    exec { "set_quota_${name}":
      provider => 'shell',
      path     => '/usr/bin:/usr/sbin:/bin',
      command  => "setquota ${name_switch} ${name} ${block_softlimit} ${block_hardlimit} ${inode_softlimit} ${inode_hardlimit} ${mount_point}",
      unless   => "quotaline=`repquota ${mount_point} | grep ${name}` && grace_block=`if [ \$(echo \${quotaline} | awk '{ print \$2 }') == \"+-\" -o \$(echo \${quotaline} | awk '{ print \$2 }') == \"++\" ] ; then echo \"yes\" ; else echo \"no\" ; fi` && block_soft=`echo \${quotaline} | awk '{ print \$4 }'` && block_hard=`echo \${quotaline} | awk '{ print \$5 }'` && if [ \${grace_block} == \"no\" ] ; then file_soft=`echo \${quotaline} | awk '{ print \$7 }'` ; file_hard=`echo \${quotaline} | awk '{ print \$8 }'` ; fi ; if [ \${grace_block} == \"yes\" ] ; then file_soft=`echo \${quotaline} | awk '{ print \$8 }'` ; file_hard=`echo \${quotaline} | awk '{ print \$9 }'` ; fi ; test \${block_soft} == ${block_softlimit} -a \${block_hard} == ${block_hardlimit} -a \${file_soft} == ${inode_softlimit} -a \${file_hard} == ${inode_hardlimit}",
    }
  }

  if $ensure == 'absent' {
    exec { "clear_quota_${name}":
      provider => 'shell',
      path     => '/usr/bin:/usr/sbin:/bin',
      command  => "setquota ${name_switch} ${name} 0 0 0 0 ${mount_point}",
      unless   => "quotaline=`repquota ${mount_point} | grep ${name}` ; if [ -z \"\${quotaline}\" ] ; then /bin/true ; else grace_block=`if [ \$(echo \${quotaline} | awk '{ print \$2 }') == \"+-\" -o \$(echo \${quotaline} | awk '{ print \$2 }') == \"++\" ] ; then echo \"yes\" ; else echo \"no\" ; fi` && block_soft=`echo \${quotaline} | awk '{ print \$4 }'` && block_hard=`echo \${quotaline} | awk '{ print \$5 }'` && if [ \${grace_block} == \"no\" ] ; then file_soft=`echo \${quotaline} | awk '{ print \$7 }'` ; file_hard=`echo \${quotaline} | awk '{ print \$8 }'` ; fi ; if [ \${grace_block} == \"yes\" ] ; then file_soft=`echo \${quotaline} | awk '{ print \$8 }'` ; file_hard=`echo \${quotaline} | awk '{ print \$9 }'` ; fi ; test \${block_soft} == 0 -a \${block_hard} == 0 -a \${file_soft} == 0 -a \${file_hard} == 0 ; fi",
    }
  }
}
