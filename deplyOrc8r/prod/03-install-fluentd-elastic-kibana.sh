#!/usr/bin/env bash

helm upgrade -i fluentd stable/fluentd -f ../charts/fluentd.yaml

#Try to tune CPU in both elasticsearch-master.yaml and elasticsearch-data.yaml accrodingly. Make it to 1.
helm upgrade -i elasticsearch-master elastic/elasticsearch \
  -f ../charts/elasticsearch-master.yaml

helm upgrade -i elasticsearch-data elastic/elasticsearch \
  -f ../charts/elasticsearch-data.yaml

#sudo helm upgrade -i elasticsearch-data2 elastic/elasticsearch \
#  -f elasticsearch-data2.yaml

helm upgrade -i elasticsearch-curator stable/elasticsearch-curator \
  -f ../charts/elasticsearch-curator.yaml

helm upgrade -i kibana stable/kibana -f ../charts/kibana.yaml

echo "Please wait for 10+ Minutes before fetching events and logs. Elasticsearch will take aprroximately 10 minutes before it actually start working"
