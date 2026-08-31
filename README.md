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
       │   [ Karpenter ]       [ Envoy Gateway ]    [ Crossplane ]
       │   (Compute Nodes)     (Gateway API Ingress) (OCI Infra)│
       │                                                        │
       │                              │                         │
       │                              ▼                         │
       │              [ External Secrets Operator (ESO) ]       │
       │                    (Vault Secret Sync)                 │
       └──────────────────────────────┬─────────────────────────┘
                                      │
                                      ▼
                         ┌──────────────────────────┐
                         │       OCI Cloud API      │
                         │ ──► Autonomous Database  │
                         │ ──► Object Storage Bucket│
                         │ ──► Existing OCI Vault   │
                         └──────────────────────────┘
</pre>

GitHub Actions publishes UI artifacts to Object Storage through an expiring,
write-only PAR URL restricted to the `releases/` prefix. The URL is stored only
as a protected GitHub Environment Secret; Flux remains the only actor that
writes to Kubernetes. The browser loads the versioned static UI release
directly from an Object Storage bucket with public object reads and disabled
listing. Manual OCI CLI creation, GitHub Environment storage, and rotation of
the write PAR are documented in
[`docs/runbooks/create-ui-write-par.md`](docs/runbooks/create-ui-write-par.md).
The corresponding CLI instructions for OCIR Actions authentication are in
[`docs/runbooks/configure-ocir-actions-secrets.md`](docs/runbooks/configure-ocir-actions-secrets.md).

<pre style="font-family: 'Courier New', Courier, monospace;">

       TODO APPLICATION RUNTIME

       Browser
         │  HTTP demo endpoint
         ▼
       [ Envoy Gateway ]
         ├── / ─────► [ Nginx UI bridge ] ◄── [ Object Storage ]
         │              (pinned release)      (public read, no list)
         └── /api ──► [ Todo API ] ───► [ Autonomous Database ]

       [ External Secrets Operator ] ◄──► [ Existing OCI Vault ]
                    │
                    ▼
          [ Scoped Kubernetes Secrets ] ───► Todo API / Crossplane
</pre>

Nginx is a temporary demo bridge because no public DNS name or TLS certificate
is available. It gives the browser one HTTP origin for the UI and the `/api`
route. In production, replace it with direct HTTPS Object Storage/CDN delivery
and an HTTPS API origin.

Karpenter-created workload nodes appear in the OCI Console as Compute
instances and in Kubernetes as Nodes and NodeClaims. They do not appear as
members of an OKE Console managed node pool because Karpenter creates the
instances directly; this is expected behavior.
