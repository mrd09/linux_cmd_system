#!/bin/sh

org_asset_id=$1
chg_asset_id=$2
base_dir="/home/nick/org"


sed -i "s/${org_asset_id}/${chg_asset_id}/g" ${base_dir}/${org_asset_id}/${org_asset_id}_400k/${org_asset_id}_400k.m3u8
