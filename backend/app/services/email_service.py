import logging
import smtplib
import threading
from email.message import EmailMessage

from app.core.config import settings
from app.services.auth_service import generate_email_token

logger = logging.getLogger("app.email")


def _smtp_username() -> str | None:
    return settings.smtp_username or settings.clinic_email



def _smtp_password() -> str | None:
    return settings.smtp_password or settings.clinic_email_password



def _from_email() -> str | None:
    return settings.smtp_from_email or settings.clinic_email



def build_confirmation_email(name: str, confirm_url: str) -> str:
    safe_name = name or "Usuário"
    return f"""
    <html>
      <body style="margin:0;padding:24px;background:#f4f6f8;font-family:Arial,sans-serif;color:#1f2937;">
        <table width="100%" cellpadding="0" cellspacing="0" role="presentation">
          <tr>
            <td align="center">
              <table width="600" cellpadding="0" cellspacing="0" role="presentation" style="max-width:600px;background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 8px 24px rgba(15,23,42,0.08);">
                <tr>
                  <td style="background:linear-gradient(135deg,#1b5e5b,#2d8a6f);padding:28px;text-align:center;color:#ffffff;">
                    <div style="font-size:28px;font-weight:700;">Clínica</div>
                    <div style="font-size:14px;opacity:0.9;margin-top:6px;">Confirmação de cadastro</div>
                  </td>
                </tr>
                <tr>
                  <td style="padding:32px;">
                    <h2 style="margin:0 0 16px;font-size:24px;color:#111827;">Bem-vindo, {safe_name}!</h2>
                    <p style="margin:0 0 16px;line-height:1.6;">Seu cadastro foi realizado com sucesso.</p>
                    <p style="margin:0 0 24px;line-height:1.6;">Para começar, confirme seu email clicando no botão abaixo:</p>
                    <div style="text-align:center;margin:32px 0;">
                      <a href="{confirm_url}" style="background:#2d8a6f;color:#ffffff;padding:14px 28px;text-decoration:none;border-radius:8px;font-weight:700;display:inline-block;">Confirmar Email</a>
                    </div>
                    <p style="margin:0 0 12px;line-height:1.6;color:#4b5563;">Se o botão não funcionar, copie e cole este link no navegador:</p>
                    <p style="margin:0;word-break:break-all;color:#1b5e5b;">{confirm_url}</p>
                  </td>
                </tr>
                <tr>
                  <td style="background:#f8fafc;padding:18px;text-align:center;color:#6b7280;font-size:12px;">
                    © 2026 Clínica — Todos os direitos reservados
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </body>
    </html>
    """



def build_confirmation_email_text(name: str, confirm_url: str) -> str:
    safe_name = name or "Usuário"
    return (
        f"Olá, {safe_name}!\n\n"
        "Seu cadastro foi realizado com sucesso.\n\n"
        "Confirme seu email no link abaixo:\n"
        f"{confirm_url}\n\n"
        "Se você não solicitou este cadastro, ignore este email."
    )



def send_email(to_email: str, subject: str, html: str, text: str | None = None) -> None:
    from_email = _from_email()
    smtp_username = _smtp_username()
    smtp_password = _smtp_password()

    if not settings.smtp_host or not from_email or not smtp_username or not smtp_password:
        logger.info("email_mock", extra={"to": to_email, "subject": subject, "html": html})
        return

    message = EmailMessage()
    message["Subject"] = subject
    message["From"] = from_email
    message["To"] = to_email
    message.set_content(text or "Seu cliente de email não suporta HTML.")
    message.add_alternative(html, subtype="html")

    with smtplib.SMTP(settings.smtp_host, settings.smtp_port, timeout=15) as server:
        if settings.smtp_use_tls:
            server.starttls()
        server.login(smtp_username, smtp_password)
        server.send_message(message)



def send_confirmation_email(email: str, name: str, token: str) -> None:
    confirm_url = f"{settings.frontend_url}/confirm-email?token={token}"
    html = build_confirmation_email(name, confirm_url)
    text = build_confirmation_email_text(name, confirm_url)
    send_email(email, "Confirme seu cadastro", html, text)



def send_confirmation_email_async(email: str | None, name: str | None, *, email_is_confirmed: bool = False) -> None:
    if not email or email_is_confirmed:
        return

    token = generate_email_token(email)

    def _worker() -> None:
        try:
            send_confirmation_email(email, name or "Usuário", token)
        except Exception:
            logger.exception("confirmation_email_failed", extra={"email": email})

    threading.Thread(target=_worker, daemon=True).start()


def build_password_reset_email(name: str, reset_url: str) -> str:
    safe_name = name or "Usuario"
    return f"""
    <html>
      <body style="margin:0;padding:24px;background:#f4f6f8;font-family:Arial,sans-serif;color:#1f2937;">
        <table width="100%" cellpadding="0" cellspacing="0" role="presentation">
          <tr>
            <td align="center">
              <table width="600" cellpadding="0" cellspacing="0" role="presentation" style="max-width:600px;background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 8px 24px rgba(15,23,42,0.08);">
                <tr>
                  <td style="background:linear-gradient(135deg,#1b5e5b,#2d8a6f);padding:28px;text-align:center;color:#ffffff;">
                    <div style="font-size:28px;font-weight:700;">Clinica</div>
                    <div style="font-size:14px;opacity:0.9;margin-top:6px;">Recuperacao de senha</div>
                  </td>
                </tr>
                <tr>
                  <td style="padding:32px;">
                    <h2 style="margin:0 0 16px;font-size:24px;color:#111827;">Ola, {safe_name}!</h2>
                    <p style="margin:0 0 16px;line-height:1.6;">Recebemos um pedido para redefinir sua senha.</p>
                    <p style="margin:0 0 24px;line-height:1.6;">Clique no botao abaixo para criar uma nova senha. Este link expira em 1 hora.</p>
                    <div style="text-align:center;margin:32px 0;">
                      <a href="{reset_url}" style="background:#2d8a6f;color:#ffffff;padding:14px 28px;text-decoration:none;border-radius:8px;font-weight:700;display:inline-block;">Redefinir senha</a>
                    </div>
                    <p style="margin:0 0 12px;line-height:1.6;color:#4b5563;">Se o botao nao funcionar, copie e cole este link no navegador:</p>
                    <p style="margin:0;word-break:break-all;color:#1b5e5b;">{reset_url}</p>
                    <p style="margin:24px 0 0;line-height:1.6;color:#6b7280;">Se voce nao solicitou a recuperacao, ignore este email.</p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </body>
    </html>
    """


def build_password_reset_email_text(name: str, reset_url: str) -> str:
    safe_name = name or "Usuario"
    return (
        f"Ola, {safe_name}!\n\n"
        "Recebemos um pedido para redefinir sua senha.\n\n"
        "Use o link abaixo para criar uma nova senha. Este link expira em 1 hora:\n"
        f"{reset_url}\n\n"
        "Se voce nao solicitou a recuperacao, ignore este email."
    )


def send_password_reset_email(email: str, name: str, token: str) -> None:
    reset_url = f"{settings.frontend_url}/reset-password?token={token}"
    html = build_password_reset_email(name, reset_url)
    text = build_password_reset_email_text(name, reset_url)
    send_email(email, "Recuperacao de senha", html, text)


def send_password_reset_email_async(email: str | None, name: str | None, token: str) -> None:
    if not email or not token:
        return

    def _worker() -> None:
        try:
            send_password_reset_email(email, name or "Usuario", token)
        except Exception:
            logger.exception("password_reset_email_failed", extra={"email": email})

    threading.Thread(target=_worker, daemon=True).start()
