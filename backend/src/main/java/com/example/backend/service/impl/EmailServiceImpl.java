package com.example.backend.service.impl;

import com.example.backend.service.EmailService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import jakarta.mail.internet.MimeMessage;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmailServiceImpl implements EmailService {

    private final JavaMailSender mailSender;

    @Async
    @Override
    public void sendRegisterOtpEmail(String toEmail, String fullName, String otpCode) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setTo(toEmail);
            helper.setSubject("[Financial Management] Xác thực tài khoản của bạn");
            helper.setText(buildRegisterEmailHtml(fullName, otpCode), true);
            mailSender.send(message);
        } catch (Exception e) {
            log.error("Lỗi gửi email xác thực tới {}: {}", toEmail, e.getMessage());
            throw new RuntimeException("Không thể gửi email xác thực");
        }
    }

    @Async
    @Override
    public void sendForgotPasswordOtpEmail(String toEmail, String fullName, String otpCode) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setTo(toEmail);
            helper.setSubject("[Financial Management] Đặt lại mật khẩu");
            helper.setText(buildForgotPasswordEmailHtml(fullName, otpCode), true);
            mailSender.send(message);
        } catch (Exception e) {
            log.error("Lỗi gửi email quên mật khẩu tới {}: {}", toEmail, e.getMessage());
            throw new RuntimeException("Không thể gửi email đặt lại mật khẩu");
        }
    }

    private String buildRegisterEmailHtml(String fullName, String otpCode) {
        return """
                <!DOCTYPE html>
                <html>
                <body style="margin:0;padding:0;background:#f5f5f5;font-family:Arial,sans-serif;">
                  <div style="max-width:600px;margin:32px auto;background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.1);">
                    <div style="background:#1B5E20;padding:24px 32px;">
                      <span style="color:#ffffff;font-size:22px;font-weight:bold;">&#128176; Financial Management</span>
                    </div>
                    <div style="padding:32px;">
                      <p style="font-size:16px;color:#212121;">Xin chào <strong>%s</strong>,</p>
                      <p style="font-size:15px;color:#424242;">Cảm ơn bạn đã đăng ký. Vui lòng dùng mã OTP bên dưới để xác thực tài khoản:</p>
                      <div style="background:#E8F5E9;border:2px solid #4CAF50;border-radius:12px;padding:20px 40px;text-align:center;margin:24px 0;">
                        <span style="font-size:40px;font-weight:bold;color:#1B5E20;letter-spacing:10px;">%s</span>
                      </div>
                      <p style="font-size:14px;color:#F44336;">&#9200; Mã có hiệu lực trong <strong>5 phút</strong></p>
                      <p style="font-size:14px;color:#F44336;">&#128274; Tuyệt đối không chia sẻ mã này với bất kỳ ai</p>
                    </div>
                    <div style="background:#F5F5F5;padding:16px;text-align:center;">
                      <p style="font-size:12px;color:#757575;margin:0;">
                        &copy; 2024 Financial Management. Nếu bạn không thực hiện yêu cầu này, hãy bỏ qua email này.
                      </p>
                    </div>
                  </div>
                </body>
                </html>
                """.formatted(fullName, otpCode);
    }

    private String buildForgotPasswordEmailHtml(String fullName, String otpCode) {
        return """
                <!DOCTYPE html>
                <html>
                <body style="margin:0;padding:0;background:#f5f5f5;font-family:Arial,sans-serif;">
                  <div style="max-width:600px;margin:32px auto;background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.1);">
                    <div style="background:#0D47A1;padding:24px 32px;">
                      <span style="color:#ffffff;font-size:22px;font-weight:bold;">&#128176; Financial Management</span>
                    </div>
                    <div style="padding:32px;">
                      <p style="font-size:16px;color:#212121;">Xin chào <strong>%s</strong>,</p>
                      <p style="font-size:15px;color:#424242;">Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản của bạn.</p>
                      <p style="font-size:15px;color:#424242;">Vui lòng dùng mã OTP bên dưới để đặt lại mật khẩu:</p>
                      <div style="background:#E3F2FD;border:2px solid #1976D2;border-radius:12px;padding:20px 40px;text-align:center;margin:24px 0;">
                        <span style="font-size:40px;font-weight:bold;color:#0D47A1;letter-spacing:10px;">%s</span>
                      </div>
                      <p style="font-size:14px;color:#F44336;">&#9200; Mã có hiệu lực trong <strong>5 phút</strong></p>
                      <div style="background:#FFEBEE;border-left:4px solid #F44336;padding:12px 16px;border-radius:4px;margin-top:16px;">
                        <p style="font-size:13px;color:#B71C1C;margin:0;">
                          &#9888;&#65039; Nếu bạn không yêu cầu điều này, tài khoản có thể đang bị đe dọa. Hãy đổi mật khẩu ngay!
                        </p>
                      </div>
                    </div>
                    <div style="background:#F5F5F5;padding:16px;text-align:center;">
                      <p style="font-size:12px;color:#757575;margin:0;">
                        &copy; 2024 Financial Management. Nếu bạn không thực hiện yêu cầu này, hãy bỏ qua email này.
                      </p>
                    </div>
                  </div>
                </body>
                </html>
                """.formatted(fullName, otpCode);
    }
}
