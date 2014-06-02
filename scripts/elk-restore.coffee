# Description:
#   elk-restore - Elasticsearch (elk) api wrapper for restoring indices.
#
# Dependencies:
#   lodash
#
# Configuration:
#   process.env.HUBOT_ELK_RESTORE_ES_URL - 'http://localhost:9200/'
#   process.env.HUBOT_ELK_RESTORE_ES_INDEX_BASE - 'logstash-'
#   process.env.HUBOT_ELK_RESTORE_ES_SNAPSHOT_REPO - ''
#   process.env.HUBOT_ELK_RESTORE_ES_SNAPSHOT_PATTERN - 'logstash-YYYY.MM.DD'
#
# Commands:
#   elk indices - Show summary of indices currently available
#   elk snapshots - Show summary of snapshots available
#   elk close <yyyy.mm.dd> - Close a particular index
#   elk restore <yyyy.mm.dd> - Restore a particular index
#

_     = require 'lodash'

elkUrl = process.env.HUBOT_ELK_RESTORE_ES_URL or 'http://localhost:9200/'
elkIndexBase = process.env.HUBOT_ELK_RESTORE_ES_INDEX_BASE or 'logstash-'
elkSnapshotRepo = process.env.HUBOT_ELK_RESTORE_ES_SNAPSHOT_REPO
elkSnapshotPattern =
  process.env.HUBOT_ELK_RESTORE_ES_SNAPSHOT_PATTERN or 'logstash-YYYY.MM.DD'

params = '{"ignore_unavailable":"true","include_global_state":"false"}'

esGet = (msg, path, callback) ->
  msg.http(elkUrl + path)
    .get() (err, res, body) ->
      # TODO handle err
      callback err, JSON.parse(body)

esPost = (msg, path, params, callback) ->
  msg.http(elkUrl + path)
    .headers("Accept:": "*/*", "Content-Type": "application/x-www-form-urlencoded", "Content-Length": params.length)
    .post(params) (err, res, body) ->
      response = JSON.parse(body)
      if res.statusCode != 200
        callback res.statusCode, "ES Error: #{response.error}"
      else
        callback null, response

esCloseOrRestore = (msg) ->
  indexDate = msg.match[2]
  if msg.match[1] == 'restore'
    if elkSnapshotRepo?
      snapshot = elkSnapshotPattern.replace /YYYY.MM.DD/, indexDate
      path = "_snapshot/#{elkSnapshotRepo}/#{snapshot}/_restore"
      msgResponse = "Restoring #{snapshot}."
    else
      msg.send "Error: HUBOT_ELK_RESTORE_ES_SNAPSHOT_REPO is not defined."
      return
  else if msg.match[1] == 'close'
    index = "#{elkIndexBase}#{indexDate}"
    path = "#{index}/_close"
    params = '{}'
    msgResponse = "Closing #{index}."

  esPost msg, path, params, (err, data) ->
    if err == null
      msg.send msgResponse
    else
      msg.send "ES StatusCode: #{err}; #{data}"

esIndices = (msg) ->
  path = "#{elkIndexBase}*/_settings"
  esGet msg, path, (err, data) ->
    # TODO this shouldn't assume contiguous sets.
    indices = (_.keys data).sort()
    msg.send 'ELK indices: ' + (_.first indices) + ' - ' + (_.last indices)

esSnapshots = (msg) ->
  path = "_snapshot/#{elkSnapshotRepo}/_all"
  esGet msg, path, (err, data) ->
    snaps = _.map(data.snapshots,'snapshot').sort()
    msg.send 'Elk snapshots: ' + (_.first snaps) + ' - ' + (_.last snaps)

# TODO bail if there's no ES_SNAPSHOT_REPO value? or allow setting from user
# TODO check the es version?
module.exports = (robot) ->
  robot.hear /elk indices/, (msg) ->
    esIndices msg

  robot.hear /elk snapshots/, (msg) -> 
    esSnapshots msg

  robot.hear /elk (close|restore) ([\d]{4}.[\d]{2}.[\d]{2})/, (msg) ->
    esCloseOrRestore msg

