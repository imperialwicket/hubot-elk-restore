hubot-elk-restore
=================

Elasticsearch (elk-focused) api wrapper for restoring daily indices.

## Installation

Update Hubot's package.json to install hubot-elk-restore from npm, and update Hubot's external-scripts.json file to include the hubot-elk-restore module.

### Update the files to include the hubot-elk-restore module:

#### package.json
    ...
    "dependencies": {
        "hubot":        ">= 2.4.0 < 3.0.0",
        ...
        "hubot-elk-restore": ">= 0.1.0"
    },
    ...

#### external-scripts.json
    ["hubot-awesome-module","hubot-elk-restore"]

    Run `npm install` (hubot will do this on start) to install hubot-elk-restore and dependencies.

## Configuration

Elk-restore supports the following configuration variables, presented with default values:

 - `HUBOT_ELK_RESTORE_ES_URL` - 'http://localhost:9200/'
 - `HUBOT_ELK_RESTORE_ES_INDEX_BASE` - 'logstash-'
 - `HUBOT_ELK_RESTORE_ES_SNAPSHOT_REPO` - ''
 - `HUBOT_ELK_RESTORE_ES_SNAPSHOT_PATTERN` - 'logstash-YYYY.MM.DD'

If a custom index base is in use, override the default 'logstash-', the default date formatting(yyyy.mm.dd) is not configurable at this time. You must configure the snapshot repo value for restore commands to function. Include the port (probably 9200) in the ES URL value, and be sure that Hubot has access to your elasticsearch cluster.

## Usage

Elk-restore is ideal for temporary restoration of daily Elasticsearch indexes (elk). Elk-restore is NOT an index manager (see [Curator](https://github.com/elasticsearch/curator)). Given these requirements, elk-restore answers the following requests:

 - elk indices: describe the currently loaded indices in the elasticsearch cluster
 - elk snapshots: describe the currently available snapshots in the configured snapshot repository
 - elk restore <yyyy.mm.dd>: restore the index for the requested day
 - elk close <yyyy.mm.dd>: close the index for the requested day

## Example

```
me> hal help elk
hal> elk close <yyyy.mm.dd> - Close a particular index
elk indices - Show summary of indices currently available
elk restore <yyyy.mm.dd> - Restore a particular index
elk snapshots - Show summary of snapshots available
me> elk indices
hal> ELK indices: logstash-2014.04.05 - logstash-2014.04.18
me> elk snapshots
hal> Elk snapshots: logstash-2014.04.04 - logstash-2014.04.07
me> elk restore 2014.04.04
hal> Restoring logstash-2014.04.04.
me> elk indices
hal> ELK indices: logstash-2014.04.04 - logstash-2014.04.18
me> elk close 2014.04.04
hal> Closing logstash-2014.04.04.
me> elk indices
hal> ELK indices: logstash-2014.04.05 - logstash-2014.04.18
```
