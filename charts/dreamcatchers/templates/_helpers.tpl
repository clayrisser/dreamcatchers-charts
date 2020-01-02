{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "dreamcatchers.name" }}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec).
*/}}
{{- define "dreamcatchers.fullname" }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a name shared accross all apps in namespace.
We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec).
*/}}
{{- define "dreamcatchers.sharedname" }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Namespace $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Calculate frontend certificate
*/}}
{{- define "dreamcatchers.frontend-certificate" }}
{{- if (not (empty .Values.ingress.frontend.certificate)) }}
{{- printf .Values.ingress.frontend.certificate }}
{{- else }}
{{- printf "%s-frontend-letsencrypt" (include "dreamcatchers.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Calculate backend certificate
*/}}
{{- define "dreamcatchers.backend-certificate" }}
{{- if (not (empty .Values.ingress.backend.certificate)) }}
{{- printf .Values.ingress.backend.certificate }}
{{- else }}
{{- printf "%s-backend-letsencrypt" (include "dreamcatchers.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Calculate pgadmin certificate
*/}}
{{- define "dreamcatchers.pgadmin-certificate" }}
{{- if (not (empty .Values.ingress.pgadmin.certificate)) }}
{{- printf .Values.ingress.pgadmin.certificate }}
{{- else }}
{{- printf "%s-pgadmin-letsencrypt" (include "dreamcatchers.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Calculate frontend hostname
*/}}
{{- define "dreamcatchers.frontend-hostname" }}
{{- if (and .Values.config.frontend.hostname (not (empty .Values.config.frontend.hostname))) }}
{{- printf .Values.config.frontend.hostname }}
{{- else }}
{{- if .Values.ingress.frontend.enabled }}
{{- printf .Values.ingress.frontend.hostname }}
{{- else }}
{{- printf "%s-frontend" (include "dreamcatchers.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate frontend base url
*/}}
{{- define "dreamcatchers.frontend-base-url" }}
{{- if (and .Values.config.frontend.baseUrl (not (empty .Values.config.frontend.baseUrl))) }}
{{- printf .Values.config.frontend.baseUrl }}
{{- else }}
{{- if .Values.ingress.frontend.enabled }}
{{- $hostname := ((empty (include "dreamcatchers.frontend-hostname" .)) | ternary .Values.ingress.frontend.hostname (include "dreamcatchers.frontend-hostname" .)) }}
{{- $path := (eq .Values.ingress.frontend.path "/" | ternary "" .Values.ingress.frontend.path) }}
{{- $protocol := (.Values.ingress.frontend.tls | ternary "https" "http") }}
{{- printf "%s://%s%s" $protocol $hostname $path }}
{{- else }}
{{- printf "http://%s" (include "dreamcatchers.frontend-hostname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate backend hostname
*/}}
{{- define "dreamcatchers.backend-hostname" }}
{{- if (and .Values.config.backend.hostname (not (empty .Values.config.backend.hostname))) }}
{{- printf .Values.config.backend.hostname }}
{{- else }}
{{- if .Values.ingress.backend.enabled }}
{{- printf .Values.ingress.backend.hostname }}
{{- else }}
{{- printf "%s-backend" (include "dreamcatchers.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate backend base url
*/}}
{{- define "dreamcatchers.backend-base-url" }}
{{- if (and .Values.config.backend.baseUrl (not (empty .Values.config.backend.baseUrl))) }}
{{- printf .Values.config.backend.baseUrl }}
{{- else }}
{{- if .Values.ingress.backend.enabled }}
{{- $hostname := ((empty (include "dreamcatchers.backend-hostname" .)) | ternary .Values.ingress.backend.hostname (include "dreamcatchers.backend-hostname" .)) }}
{{- $path := (eq .Values.ingress.backend.path "/" | ternary "" .Values.ingress.backend.path) }}
{{- $protocol := (.Values.ingress.backend.tls | ternary "https" "http") }}
{{- printf "%s://%s%s" $protocol $hostname $path }}
{{- else }}
{{- printf "http://%s" (include "dreamcatchers.backend-hostname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate postgres url
*/}}
{{- define "dreamcatchers.postgres-url" }}
{{- $postgres := .Values.config.postgres }}
{{- if $postgres.internal }}
{{- $credentials := (printf "%s:%s" $postgres.username $postgres.password) }}
{{- printf "postgresql://%s@%s-postgres:5432/%s" $credentials (include "dreamcatchers.fullname" .) $postgres.database }}
{{- else }}
{{- if $postgres.url }}
{{- printf $postgres.url }}
{{- else }}
{{- printf "postgresql://%s@%s:%s/%s" $credentials $postgres.host $postgres.port $postgres.database }}
{{- end }}
{{- end }}
{{- end }}
