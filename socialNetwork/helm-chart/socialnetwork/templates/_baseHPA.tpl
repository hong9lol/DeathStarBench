{{- define "socialnetwork.templates.baseHPA" }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  annotations:
    "helm.sh/hook": "post-install"
  name: {{ .Values.name }}
  namespace: default
spec:
  maxReplicas: {{ .Values.maxReplicas | default .Values.global.hpa.maxReplicas }}
  minReplicas: {{ .Values.minReplicas | default .Values.global.hpa.minReplicas }}
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.targetCPUUtilization | default .Values.global.hpa.targetCPUUtilization }}
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ .Values.name }}
{{- end }}