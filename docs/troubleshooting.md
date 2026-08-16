# Troubleshooting

## Python no reconocido

Instala Python 3.11 y reinicia la terminal. Verifica:

```powershell
python --version
```

## Ollama no responde

Comprueba que el servicio este levantado:

```powershell
ollama list
```

Si falla, abre Ollama manualmente y vuelve a probar.

## Modelo no encontrado

Descargalo otra vez:

```powershell
ollama pull qwen2.5:7b
```

## Error de conexion a `localhost:11434`

Revisa la configuracion:

```toml
base_url = "http://localhost:11434/v1"
```

## Entorno virtual no activa

Permite scripts temporalmente:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
```

## Dependencias no instalan

Actualiza `pip`:

```powershell
python -m pip install --upgrade pip
```

Luego reinstala:

```powershell
pip install -r requirements.txt
```
