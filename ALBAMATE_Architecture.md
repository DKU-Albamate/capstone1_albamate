# ALBAMATE 시스템 아키텍처 다이어그램

## 전체 시스템 아키텍처

```mermaid
graph TB
    subgraph "📱 Frontend Layer"
        A[Flutter Mobile App<br/>Android, iOS, Web PWA<br/>Material Design 3]
    end
    
    subgraph "🌐 Render Cloud Platform"
        B[Main Backend Service<br/>backend-vgbf.onrender.com<br/>Node.js 18, Port 3000<br/>Auto-deploy GitHub<br/>Health Check: /ocr/health]
        C[Schedule Backend Service<br/>backend-schedule-xxxx.onrender.com<br/>Node.js 18, Port 10000<br/>Auto-deploy GitHub<br/>Health Check: /api/schedules/health]
    end
    
    subgraph "🗄️ Database Layer"
        D[Supabase PostgreSQL<br/>사용자, 일정, 그룹 데이터]
        E[MongoDB Atlas<br/>스케줄 관리 데이터]
        F[Firebase<br/>인증, 푸시알림]
    end
    
    subgraph "🤖 AI Services"
        G[CLOVA OCR<br/>이미지 텍스트 추출]
        H[Google Gemini 2.5 Flash Lite<br/>스케줄 분석]
    end
    
    subgraph "🔄 CI/CD Pipeline"
        I[GitHub Repository]
        J[Render Auto-deploy]
        K[Health Check Monitoring]
    end
    
    A --> B
    A --> C
    B --> D
    B --> E
    B --> F
    B --> G
    B --> H
    C --> E
    C --> F
    I --> J
    J --> B
    J --> C
    J --> K
    
    style A fill:#4CAF50,stroke:#2E7D32,stroke-width:2px,color:#fff
    style B fill:#2196F3,stroke:#1976D2,stroke-width:2px,color:#fff
    style C fill:#2196F3,stroke:#1976D2,stroke-width:2px,color:#fff
    style D fill:#FF9800,stroke:#F57C00,stroke-width:2px,color:#fff
    style E fill:#9C27B0,stroke:#7B1FA2,stroke-width:2px,color:#fff
    style F fill:#FF5722,stroke:#E64A19,stroke-width:2px,color:#fff
    style G fill:#00BCD4,stroke:#0097A7,stroke-width:2px,color:#fff
    style H fill:#8BC34A,stroke:#689F38,stroke-width:2px,color:#fff
    style I fill:#607D8B,stroke:#455A64,stroke-width:2px,color:#fff
    style J fill:#607D8B,stroke:#455A64,stroke-width:2px,color:#fff
    style K fill:#607D8B,stroke:#455A64,stroke-width:2px,color:#fff
```

## 데이터 플로우 다이어그램

```mermaid
sequenceDiagram
    participant F as 📱 Flutter App
    participant R as 🌐 Render Services
    participant S as 🗄️ Supabase
    participant M as 🍃 MongoDB
    participant FB as 🔥 Firebase
    participant C as 📸 CLOVA OCR
    participant G as 🤖 Gemini AI
    
    F->>R: API Request
    R->>S: Database Query
    R->>M: Schedule Data
    R->>FB: Authentication
    R->>C: Image Processing
    C->>G: OCR Result
    G->>R: AI Analysis
    R->>F: Response
    
    Note over F,R: Real-time Communication
    Note over S,M,FB: Data Persistence
    Note over C,G: AI Processing
```

## 마이크로서비스 아키텍처

```mermaid
graph LR
    subgraph "📱 Client Layer"
        A1[Android App]
        A2[iOS App]
        A3[Web PWA]
    end
    
    subgraph "🌐 API Gateway"
        B[Load Balancer]
    end
    
    subgraph "🖥️ Backend Services"
        C1[Main Backend<br/>Port 3000]
        C2[Schedule Backend<br/>Port 10000]
    end
    
    subgraph "🗄️ Data Layer"
        D1[Supabase<br/>PostgreSQL]
        D2[MongoDB Atlas]
        D3[Firebase]
    end
    
    subgraph "🤖 AI Layer"
        E1[CLOVA OCR]
        E2[Gemini AI]
    end
    
    A1 --> B
    A2 --> B
    A3 --> B
    B --> C1
    B --> C2
    C1 --> D1
    C1 --> D2
    C1 --> D3
    C2 --> D2
    C2 --> D3
    C1 --> E1
    C1 --> E2
    
    style A1 fill:#4CAF50,stroke:#2E7D32,stroke-width:2px,color:#fff
    style A2 fill:#4CAF50,stroke:#2E7D32,stroke-width:2px,color:#fff
    style A3 fill:#4CAF50,stroke:#2E7D32,stroke-width:2px,color:#fff
    style B fill:#FF9800,stroke:#F57C00,stroke-width:2px,color:#fff
    style C1 fill:#2196F3,stroke:#1976D2,stroke-width:2px,color:#fff
    style C2 fill:#2196F3,stroke:#1976D2,stroke-width:2px,color:#fff
    style D1 fill:#9C27B0,stroke:#7B1FA2,stroke-width:2px,color:#fff
    style D2 fill:#FF5722,stroke:#E64A19,stroke-width:2px,color:#fff
    style D3 fill:#00BCD4,stroke:#0097A7,stroke-width:2px,color:#fff
    style E1 fill:#8BC34A,stroke:#689F38,stroke-width:2px,color:#fff
    style E2 fill:#607D8B,stroke:#455A64,stroke-width:2px,color:#fff
```

## 배포 파이프라인

```mermaid
graph TD
    A[GitHub Repository] --> B[Code Push]
    B --> C[GitHub Webhook]
    C --> D[Render Build]
    D --> E[Environment Setup]
    E --> F[Dependency Install]
    F --> G[Application Start]
    G --> H[Health Check]
    H --> I{Health OK?}
    I -->|Yes| J[Deploy Success]
    I -->|No| K[Rollback]
    K --> L[Previous Version]
    J --> M[Production Live]
    
    style A fill:#24292E,stroke:#000,stroke-width:2px,color:#fff
    style B fill:#28A745,stroke:#22863A,stroke-width:2px,color:#fff
    style C fill:#0366D6,stroke:#0056B3,stroke-width:2px,color:#fff
    style D fill:#FF9800,stroke:#F57C00,stroke-width:2px,color:#fff
    style E fill:#2196F3,stroke:#1976D2,stroke-width:2px,color:#fff
    style F fill:#4CAF50,stroke:#2E7D32,stroke-width:2px,color:#fff
    style G fill:#8BC34A,stroke:#689F38,stroke-width:2px,color:#fff
    style H fill:#FF5722,stroke:#E64A19,stroke-width:2px,color:#fff
    style I fill:#FFC107,stroke:#FFA000,stroke-width:2px,color:#000
    style J fill:#4CAF50,stroke:#2E7D32,stroke-width:2px,color:#fff
    style K fill:#F44336,stroke:#D32F2F,stroke-width:2px,color:#fff
    style L fill:#9E9E9E,stroke:#757575,stroke-width:2px,color:#fff
    style M fill:#4CAF50,stroke:#2E7D32,stroke-width:2px,color:#fff
``` 