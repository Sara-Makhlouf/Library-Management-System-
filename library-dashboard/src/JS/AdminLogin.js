import React, { useState, } from "react";
import "../CSS/AdminLogin.css";
import { COLORS } from "../Constants/ColorsUse";
import LanguageIcon from '@mui/icons-material/Language';
import EmailOutlinedIcon from "@mui/icons-material/EmailOutlined";
import LockOutlinedIcon from "@mui/icons-material/LockOutlined";

export default function AdminLoginPage() {
  const [isRTL, setIsRTL] = useState(false);
  const [step, setStep] = useState("login");

  const toggleLanguage = () => setIsRTL(!isRTL);

  return (
    
    <div className="login-wrapper" dir={isRTL ? "rtl" : "ltr"}>

      <div className="glass-orb orb-primary" style={{ backgroundColor: COLORS.Primary }}></div>
      <div className="glass-orb orb-accent" style={{ backgroundColor: COLORS.Accent }}></div>

      <div className="main-card">
        <div className="side-info" style={{ backgroundColor: COLORS.Primary }}>
          <div className="brand-section">
            <div  className="logo-box" style={{ background: 'white', padding: '2px', borderRadius: '12px' }}>
              <img src="/3.png" className="app-logo" alt="logo" />
            </div>
            <h2 className="brand-name">{isRTL ? "لوحة التحكم" : "Library Panel"}<span style={{ color: COLORS.Secondary }}></span></h2>
          </div>
<div className="welcome-content">
  <h1 className="hero-title">
    {isRTL ? "محراب" : "Sanctuary"}<br />
    <span style={{ color: COLORS.Secondary }}>{isRTL ? "المعرفة" : "of Wisdom"}</span>
  </h1>
  <p className="hero-subtitle">
    {isRTL 
      ? "هنا حيث تلتقي العقول بالصفحات، لنبني جسراً بين الماضي العريق والمستقبل المشرق." 
      : "Where minds meet pages, building a timeless bridge between ancient heritage and a bright future."}
  </p>
</div>

          <div className="mini-stats">
            <div className="stat-pill">
              <span className="stat-val" style={{ color: COLORS.Secondary }}>1.2k+</span>
              <span className="stat-lab">{isRTL ? "نشاط اليوم" : "Daily Activity"}</span>
            </div>
            <div className="stat-pill">
              <span className="stat-val" style={{ color: COLORS.Accent }}>99.9%</span>
              <span className="stat-lab">{isRTL ? "استقرار النظام" : "Uptime Status"}</span>
            </div>
          </div>
        </div>

        <div className="form-section">
          <button onClick={toggleLanguage} className="lang-switcher" style={{ color: COLORS.Primary }}>
           <>
  <LanguageIcon style={{ fontSize: "1.1rem" }} />
  <span>{isRTL ? "English" : "العربية"}</span>
</>
          </button>

          <div className="form-container">
            {step === "login" ? (
              <div className="fade-in">
                <h2 className="form-title" style={{ color: COLORS.Primary }}>
                  {isRTL ? "تسجيل الدخول" : "Sign In"}
                </h2>
                <p className="form-desc" style={{ color: COLORS.Text }}>
                  {isRTL ? "الرجاء إدخال بيانات الاعتماد للوصول" : "Please enter your credentials to proceed"}
                </p>
                
                <form onSubmit={(e) => { e.preventDefault(); setStep("2fa"); }}>
                  <div className="input-group">
<label className="input-label" style={{ color: COLORS.Primary }}>
  {isRTL ? (
    <>
      <EmailOutlinedIcon className="label-icon" />
      البريد المهني
    </>
  ) : (
    <>
      <EmailOutlinedIcon className="label-icon" />
      Work Email
    </>
  )}
</label>                    <input type="email" placeholder="name@company.com" className="custom-input" required />
                  </div>
                  <div className="input-group">
<label className="input-label" style={{ color: COLORS.Primary }}>
  {isRTL ? (
    <>
      <LockOutlinedIcon className="label-icon" />
      كلمة المرور
    </>
  ) : (
    <>
      <LockOutlinedIcon className="label-icon" />
      Password
    </>
  )}
</label>                    <input type="password" placeholder="••••••••" className="custom-input" required />
                  </div>
                  
                  <button type="submit" className="btn-main" style={{ backgroundColor: COLORS.Primary }}>
                    {isRTL ? "دخول النظام" : "Access System"}
                  </button>
                </form>
              </div>
            ) : (
              <div className="fade-in">
                <h2 className="form-title" style={{ color: COLORS.Primary }}>{isRTL ? "تحقق الأمان" : "Security Check"}</h2>
                <p className="form-desc">{isRTL ? "أدخل الرمز المكون من 4 أرقام" : "Enter the 4-digit security code"}</p>
                
                <div className="otp-container" style={{ display: 'flex', gap: '15px', marginBottom: '30px' }}>
                  {[0, 1, 2, 3].map((i) => (
                    <input key={i} type="text" maxLength="1" className="otp-box" style={{ width: '65px', height: '70px', textAlign: 'center', fontSize: '1.5rem', fontWeight: 'bold', borderRadius: '12px', border: '1px solid #e2e8f0', background: '#f8fafc' }} />
                  ))}
                </div>
                
                <button className="btn-main" style={{ backgroundColor: COLORS.Accent }}>
                  {isRTL ? "تحقق الآن" : "Verify Identity"}
                </button>
                <button onClick={() => setStep("login")} className="btn-back" style={{ width: '100%', background: 'none', border: 'none', marginTop: '20px', color: COLORS.Secondary, fontWeight: '600', cursor: 'pointer' }}>
                  {isRTL ? "العودة للرئيسية" : "Back to Login"}
                </button>
              </div>
            )}
            <div className="login-meta">
  <p>{isRTL ? "آخر تسجيل دخول: اليوم 09:42" : "Last login: Today at 09:42"}</p>
  <p>{isRTL ? "الموقع: Roosendaal, NL" : "Location: Roosendaal, NL"}</p>
</div>
            <p style={{ textAlign: 'center', marginTop: '50px', fontSize: '0.8rem', color: '#94a3b8' }}>
              © 2026 LibraryPanel Enterprise. All rights reserved.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}