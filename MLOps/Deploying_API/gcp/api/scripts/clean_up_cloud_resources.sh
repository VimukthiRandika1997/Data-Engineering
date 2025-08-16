#!/bin/bash

pushd ../Iac

    pushd cloud_run_service
        bash create_service.sh destroy
    popd

    pushd base_resources
        bash create_resources.sh destroy 
    popd

    pushd remote_tf_state_bucket
        bash create_resources.sh destroy 
    popd

popd

