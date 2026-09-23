# IRL Streamer – Android (RTMP + SRT)

App otimizado para lives IRL no **Android**, com suporte a **RTMP e SRT**.

## Destaques

- Streaming real via **rtmp_streaming** (RootEncoder)
- Suporte a **SRT** (recomendado para IRL – muito mais estável em 4G/5G)
- Suporte a **RTMP** (Twitch, YouTube, etc.)
- Troca de câmera (frente/trás) mesmo durante a live
- Reconnect automático
- Overlays + URLs interativas
- Controles pensados para uso com uma mão

## Como rodar (Android)

```bash
cd irl_streamer
flutter pub get
flutter run
```

Ou gere o APK:

```bash
flutter build apk --release
```

O arquivo fica em: `build/app/outputs/flutter-apk/app-release.apk`

## Como fazer a live

1. Abra o app
2. Toque em **Configurações**
3. Escolha o protocolo:
   - **SRT** → melhor para IRL (rede instável)
   - **RTMP** → mais simples (Twitch/YouTube direto)
4. Cole a URL + chave
5. Toque no botão vermelho **LIVE**

### Exemplos de URL

**SRT (recomendado):**
```
srt://seu-servidor:9000?streamid=#!::r=live/stream,m=publish
```

**RTMP:**
```
rtmp://live.twitch.tv/app
rtmp://a.rtmp.youtube.com/live2
```

## Dica de estabilidade

Para IRL comece com:
- 720p
- 30 fps
- 2000–3000 kbps

SRT tolera bem mais perda de pacotes que RTMP.

## Observação

Este projeto é focado em **Android**.  
O plugin também funciona em iOS, mas o foco atual é Android.

---
Versão com SRT + RTMP para quem precisa de estabilidade real em movimento.
