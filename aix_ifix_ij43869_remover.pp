#
#  2023/03/29 - cp - This is going to be a pain in the rear.  IJ44799, etc. are
#		are replacements for the IJ43869 ifix, but they won't install when
#		IJ43869 is present, so we have to remove that one first.
#
#-------------------------------------------------------------------------------
#
class aix_ifix_ij43869_remover {

    #  This only applies to AIX and maybe VIOS in later versions
    if ($::facts['osfamily'] == 'AIX') {

        #  Set the ifix ID up here to be used later in various names
        $ifixName = 'IJ43869'

        #  Make sure we create/manage the ifix staging directory
        require aix_file_opt_ifixes

        #
        #  For now, we're skipping anything that reads as a VIO server.
        #  We have no matching versions of this ifix / VIOS level installed.
        #
        unless ($::facts['aix_vios']['is_vios']) {

            #
            #  Friggin' IBM...  The ifix ID that we find and capture in the fact has the
            #  suffix allready applied.
            #
            if ($::facts['kernelrelease'] == '7200-05-03-2148') {
                $ifixSuffix = 'm3c'
                $ifixBuildDate = '230216'
            }
            else {
                if ($::facts['kernelrelease'] in ['7200-05-04-2220']) {
                    $ifixSuffix = 'm4b'
                    $ifixBuildDate = '230216'
                }
                else {
                    if ($::facts['kernelrelease'] == '7200-05-05-2246') {
                        $ifixSuffix = 'm5b'
                        $ifixBuildDate = '230216'
                    }
                    else {
                        $ifixSuffix = 'unknown'
                        $ifixBuildDate = 'unknown'
                    }
                }
            }
        }
        else {
            if ($::facts['aix_vios']['version'] == '3.1.3.14') {
                $ifixSuffix = 'm3a'
                $ifixBuildDate = '221025'
            }
            else {
                if ($::facts['aix_vios']['version'] == '3.1.4.10') {
                    $ifixSuffix = 's5a'
                    $ifixBuildDate = '221212'
                }
                else {
                    $ifixSuffix = 'unknown'
                    $ifixBuildDate = 'unknown'
                }
            }
        }

        #  Add the name and suffix to make something we can find in the fact
        $ifixFullName = "${ifixName}${ifixSuffix}"

        #  If we set our $ifixSuffix and $ifixBuildDate, we'll continue
        if (($ifixSuffix != 'unknown') and ($ifixBuildDate != 'unknown')) {

            #
            #  2023/02/17 - cp - This is where things change for the remover.  We 
            #               only do the work if it *IS* present instead of absent.
            #
            if ($ifixFullName in $::facts['aix_ifix']['hash'].keys) {
 
                #  Build up the complete name of the ifix staging target
                $ifixStagingTarget = "/opt/ifixes/${ifixName}${ifixSuffix}.${ifixBuildDate}.epkg.Z"

                #  Remove the staged file from the previous ifix
                file { "$ifixStagingTarget" :
                    ensure  => 'absent',
                }

                #  GAG!  Use an exec resource to remove it, since we have no other option yet
                exec { "emgr-remove-${ifixName}":
                    path     => '/bin:/sbin:/usr/bin:/usr/sbin:/etc',
                    command  => "/usr/sbin/emgr -r -L $ifixFullName",
                }

            }

        }

    }

}
