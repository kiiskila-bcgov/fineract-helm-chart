{{/*
Expand the name of the chart.
*/}}
{{- define "n8n.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "n8n-worker.name" -}}
{{- printf "%s-%s" .Chart.Name "-worker" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "n8n-proxy.name" -}}
{{- printf "%s-%s" .Chart.Name "-proxy" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "n8n.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "n8n-worker.fullname" -}}
{{- printf "%s-%s" .Release.Name "-worker" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "n8n-proxy.fullname" -}}
{{- printf "%s-%s" .Release.Name "-proxy" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "n8n.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "n8n.labels" -}}
helm.sh/chart: {{ include "n8n.chart" . }}
{{ include "n8n.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/role: "n8n-master"
{{- end }}

{{- define "n8n-worker.labels" -}}
app.kubernetes.io/role: "n8n-worker"
{{- end }}

{{- define "n8n-proxy.labels" -}}
app.kubernetes.io/role: "n8n-proxy"
{{- end }}

{{/*
Selector labels
*/}}
{{- define "n8n.selectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/role: "n8n-master"
{{- end }}

{{- define "n8n-worker.selectorLabels" -}}
app.kubernetes.io/role: "n8n-worker"
{{- end }}


{{- define "n8n-proxy.selectorLabels" -}}
app.kubernetes.io/role: "n8n-proxy"
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "n8n.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "n8n.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Create a list of config files for n8n */}}
{{- define "n8n.configFiles" -}}
    {{- $conf_val := "" }}
    {{- $sec_val  := "" }}
    {{- $separator  := "" }}
    {{- if .Values.config }}
        {{- $conf_val = "/n8n-config/config.json" }}
    {{- end }}
    {{- if .Values.secret }}
        {{- $sec_val = "/n8n-secret/secret.json" }}
    {{- end }}
    {{- if and .Values.config .Values.secret }}
        {{- $separator  = "," }}
    {{- end }}
    {{- print $conf_val $separator $sec_val }}
{{- end }}


{{/* PVC existing, emptyDir, Dynamic */}}
{{- define "n8n.pvc" -}}
{{- if or (not .Values.persistence.enabled) (eq .Values.persistence.type "emptyDir") -}}
          emptyDir: {}
{{- else if and .Values.persistence.enabled .Values.persistence.existingClaim -}}
          persistentVolumeClaim:
            claimName: {{ .Values.persistence.existingClaim }}
{{- else if and .Values.persistence.enabled (eq .Values.persistence.type "dynamic")  -}}
          persistentVolumeClaim:
            claimName: {{ include "n8n.fullname" . }}
{{- end }}
{{- end }}