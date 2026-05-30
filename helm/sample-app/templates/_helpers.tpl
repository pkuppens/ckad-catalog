{{- define "sample-app.labels" -}}
app.kubernetes.io/part-of: ckad-sample
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}
