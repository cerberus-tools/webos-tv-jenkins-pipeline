#!/bin/bash
CLEAN_BUILD_MACHINE="k6lpwee"
STRGEN_VERSION="4.8.7"

if [ -n "${run_OAD}" ]; then
    if [ "${run_OAD}" = "true" ]; then
		if [ "${build_codename}" = "jcl4tvmr" ] || [ "${build_codename}" = "jcl4tv" ] || [ "${build_codename}" = "webos4tv" ] || [ "${build_codename}" = "japoon" ]; then
			runOAD()
			{
				echo $1	
                #dir_platform=${build_codename:0:3}
                #dir_platform=`echo ${build_codename} | cut -c 1-3`
                dir_platform="jcl"
                mkdir -p /binary/build_results/OAD/${dir_platform}/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}/
				mkdir -p /binary/build_results/OAD/${dir_platform}/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}/$1
				cd /binary/build_results/OAD/${dir_platform}/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}/$1
				
				echo "[OAD] copy ota epk file to OAD workspace."      
				cp -d /binary/build_results/starfish_verifications/$JOB_NAME/$BUILD_NUMBER/${CLEAN_BUILD_MACHINE}/starfish-$1-secured/*_ota_V3_SECURED.epk /binary/build_results/OAD/${dir_platform}/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}/$1/
						
				#echo "git clone the files that make the oad stream files."
				#git clone ssh://gatekeeper.tvsw@wall.lge.com:29448/oad_files
				#cd oad_files
				#git checkout GLD4TV
				#cp * ../
				#cd ../
				
                echo "get the streamgenerator tool form webos.lge.com."
                wget http://webos.lge.com/webos-pro/x86_64/official/streamgenerator/streamgenerator-x86_64-${STRGEN_VERSION}.tar.bz2
                tar -xjvf streamgenerator-x86_64-${STRGEN_VERSION}.tar.bz2
                
				echo "delete symbolic link file."
				if [ -L "starfish-$1-secured-${CLEAN_BUILD_MACHINE}-prodkey_ota_V3_SECURED.epk" ]; then
					rm /binary/build_results/OAD/${dir_platform}/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}/$1/starfish-$1-secured-${CLEAN_BUILD_MACHINE}-prodkey_ota_V3_SECURED.epk
				fi
				
				echo "run make OTA."
				python /binary/build_results/OAD/${dir_platform}/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}/$1/makeOTA.py

				rm /binary/build_results/OAD/${dir_platform}/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}/$1/*.epk
				cp -rf /binary/build_results/OAD/${dir_platform}/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}/$1/starfish-* /binary/build_results/OAD/${dir_platform}/${CLEAN_BUILD_MACHINE}/
				rm -rf /binary/build_results/OAD/${dir_platform}/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}/
			}	

			if [ "${region_atsc}" = "true" ]; then
				result=$(runOAD atsc)
			fi

			if [ "${region_dvb}" = "true" ]; then
				result=$(runOAD dvb)
			fi

			if [ "${region_arib}" = "true" ]; then
				result=$(runOAD arib)
			fi	
	
		else
			mkdir /binary/build_results/OAD/beehive/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}
			cd /binary/build_results/OAD/beehive/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}

			echo "[OAD] copy ota epk file to OAD workspace."        
			cp -d /binary/build_results/starfish_verifications/$JOB_NAME/$BUILD_NUMBER/${CLEAN_BUILD_MACHINE}/starfish-*-secured/*_ota_V3_SECURED.epk /binary/build_results/OAD/beehive/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}
					
			echo "git clone the files that make the oad stream files."
			git clone ssh://gatekeeper.tvsw@wall.lge.com:29448/oad_files
			cd oad_files
			git checkout ${CLEAN_BUILD_MACHINE}
			cp * ../
			cd ../

			echo "delete symbolic link file."
			if [ -L "starfish-dvb-secured-${CLEAN_BUILD_MACHINE}-prodkey_ota_V3_SECURED.epk" ]; then
				rm /binary/build_results/OAD/beehive/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}/starfish-dvb-secured-${CLEAN_BUILD_MACHINE}-prodkey_ota_V3_SECURED.epk
			fi
			if [ -L "starfish-atsc-secured-${CLEAN_BUILD_MACHINE}-prodkey_ota_V3_SECURED.epk" ]; then
				rm /binary/build_results/OAD/beehive/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}/starfish-atsc-secured-${CLEAN_BUILD_MACHINE}-prodkey_ota_V3_SECURED.epk
			fi

			python /binary/build_results/OAD/beehive/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}/oadtest.py
			cp -rf /binary/build_results/OAD/beehive/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}/starfish-* /binary/build_results/OAD/beehive/${CLEAN_BUILD_MACHINE}/
			rm -rf /binary/build_results/OAD/beehive/${CLEAN_BUILD_MACHINE}/${BUILD_NUMBER}
			fi
		fi
fi
