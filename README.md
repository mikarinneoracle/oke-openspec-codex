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

UI-artefaktit julkaistaan GitHub Actionsista Object Storageen määräaikaisella,
vain `releases/`-prefiksiin rajatulla write-PAR-URL:lla. URL säilytetään vain
suojattuna GitHub Environment Secretinä; Flux on edelleen ainoa Kubernetesiin
kirjoittava toimija. Selain lataa versionoidun staattisen UI-releasen suoraan
Object Storage -bucketista, jossa object-read on julkinen mutta listaus estetty.
Write-PARin manuaalinen OCI CLI -luonti, GitHub Environment -tallennus ja
rotaatio on kuvattu tiedostossa
[`docs/runbooks/create-ui-write-par.md`](docs/runbooks/create-ui-write-par.md).

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

Nginx on väliaikainen demo-bridge, koska käytettävissä ei ole julkista DNS-nimeä
ja TLS-sertifikaattia. Se antaa selaimelle saman HTTP-originin UI:lle ja
`/api`-reitille. Tuotannossa se korvataan suoralla HTTPS Object Storage/CDN
-toimituksella ja HTTPS API -originilla.
