#!/usr/bin/env bash

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source ${ABM_WORK_DIR}/scripts/helpers/include.sh

ASMCLI_BINARY=${ABM_WORK_DIR}/bin/asmcli
ASM_OUTPUT_DIR=${ASM_TEMP_DIR}/asm-${ASM_RELEASE}
for cluster_name in $(get_cluster_names); do
    load_cluster_config ${cluster_name}

    title_no_wait "Installing Anthos Service Mesh on ${cluster_name}"

    kubeconfig_file=${BMCTL_WORKSPACE_DIR}/${cluster_name}/${cluster_name}-kubeconfig
    export KUBECONFIG=${kubeconfig_file}

    unset CLUSTER_NAME

    bold_no_wait "Validate the project and the cluster"
    print_and_execute "${ASMCLI_BINARY} validate --kubeconfig ${kubeconfig_file} --output_dir ${ASM_OUTPUT_DIR} --platform multicloud"

    bold_no_wait "Run the prechecks"
    print_and_execute "${ASM_OUTPUT_DIR}/istioctl experimental precheck"

    bold_no_wait "Install Anthos Service Mesh"    
    print_and_execute "${ASMCLI_BINARY} install --fleet_id ${PLATFORM_PROJECT_ID} --kubeconfig ${kubeconfig_file} --output_dir ${ASM_OUTPUT_DIR} --platform multicloud --enable_all --ca mesh_ca"

    GATEWAY_NAMESPACE=asm-gateway
    bold_no_wait "Install Anthos Service Mesh gateway"
    print_and_execute "kubectl create namespace ${GATEWAY_NAMESPACE}"
    print_and_execute "kubectl label namespace ${GATEWAY_NAMESPACE} istio-injection- istio.io/rev=${ASM_REVISION} --overwrite"

    ingressgateway_yaml=${ASM_OUTPUT_DIR}/ingressgateway.yaml
    print_and_execute "curl --location --output ${ingressgateway_yaml} --show-error --silent https://raw.githubusercontent.com/GoogleCloudPlatform/anthos-service-mesh-packages/release-${ASM_RELEASE}-asm/samples/gateways/istio-ingressgateway.yaml"
    print_and_execute "kubectl apply -n asm-gateway -f ${ingressgateway_yaml}"
done

check_local_error
total_runtime
exit ${local_error}
