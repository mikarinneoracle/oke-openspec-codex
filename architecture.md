<pre style="font-family: 'Courier New', Courier, monospace;">
┌────────────────────────────────────────────────────────┐
       │               DEVELOPER WORKSPACE (Local)              │
       │                                                        │
       │     [ Human Developer ] <───► [ OpenAI Codex ]         │
       │                                      │                 │
       │  ┌───────────────────────────────────┼────────────────┐│
       │  │ READS PERMANENT RULES             │ USES TO ACT    ││
       │  ▼                                   ▼                ││
       │ [ AGENTS.md ]                 [ .agents/skills/ ]     ││
       │ (Guardrails & Limits)         (e.g., read-cluster.md) ││
       │  │                                   │                ││
       │  │ 1. Evaluates Rules                │ 2. Executes    ││
       │  ▼                                   ▼    Read-Only   ││
       │ ┌──────────────────────────────────────────────────┐  ││
       │ │   openspec/changes/ (Dynamic Working Files)      │  ││
       │ │                                                  │  ││
       │ │  ├── proposal.md   (What & Why - Alignment)      │  ││
       │ │  ├── design.md     (How & Architecture)          │  ││
       │ │  └── tasks.md      (Live Checklist & Status)     │  ││
       │ └────────────────────────────┬─────────────────────┘  ││
       │                              │                        ││
       │                              ▼ (Generates & Validates)││
       │               [ Declarative K8s/OCI YAMLs ]           ││
       └──────────────────────────────┬────────────────────────┘
                                      │
                                      ▼ (Git Commit, Push & PR Approval)
       ┌────────────────────────────────────────────────────────┐
       │                LIVE KUBERNETES CLUSTER                 │
       │                                                        │
       │          [ Flux (GitOps Reconciliation Engine) ]       │
       │                              │                         │
       │        ┌─────────────────────┼─────────────────────┐   │
       │        ▼                     ▼                     ▼   │
       │   [ Karpenter ]       [ Gateway API ]       [ Crossplane ]
       │   (Compute Nodes)     (Traffic Routes)      (OCI Infra)
       │                                                    │
       │                                                    ▼   │
       │                                          ┌──────────────────┐
       │                                          │  OCI Cloud API   │
       │                                          │ ──► Autonomous DB│
       │                                          │ ──► OS Bucket    │
       │                                          └──────────────────┘
</pre>
