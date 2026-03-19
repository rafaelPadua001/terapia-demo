from datetime import datetime


def send_whatsapp_message(phone: str, message: str) -> None:
    timestamp = datetime.utcnow().isoformat()
    print(f"[{timestamp}] Sending WhatsApp to {phone}: {message}")
