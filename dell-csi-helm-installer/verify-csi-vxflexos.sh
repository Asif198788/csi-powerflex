#!/bin/bash
#
# Copyright (c) 2020 Dell Inc., or its subsidiaries. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0

#
# verify-csi-vxflexos method
function verify-csi-vxflexos() {
  verify_k8s_versions "1.20" "1.22"
  verify_openshift_versions "4.6" "4.8"
  verify_namespace "${NS}"
  verify_helm_values_version "${DRIVER_VERSION}"
  verify_required_secrets "${RELEASE}-config"
  verify_sdc_installation
  verify_alpha_snap_resources
  verify_snap_requirements
  verify_helm_3
}

# Check if the SDC is installed and the kernel module loaded
function verify_sdc_installation() {
  if [ ${NODE_VERIFY} -eq 0 ]; then
    return
  fi
  log step "Verifying the SDC installation"

  local SDC_MINION_NODES=$(run_command kubectl get nodes -o wide | grep -v -e master -e INTERNAL -e infra | awk ' { print $6; }')

  error=0
  missing=()
  for node in $SDC_MINION_NODES; do
    # check is the scini kernel module is loaded
    run_command ssh ${NODEUSER}@$node "/sbin/lsmod | grep scini" >/dev/null 2>&1
    rv=$?
    if [ $rv -ne 0 ]; then
      missing+=($node)
      error=1
      found_warning "SDC was not found on node: $node"
    fi
  done
  check_error error
}



