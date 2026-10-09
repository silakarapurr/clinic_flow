import React, { useState } from 'react';
import { 
  ShieldCheck, 
  Lock, 
  User, 
  KeyRound, 
  ArrowRight, 
  AlertCircle,
  Sparkles,
  Building2
} from 'lucide-react';
import { authService } from '../services/authService';

export default function AdminLogin({ onLoginSuccess }) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e) => {
    e?.preventDefault();
    setError('');
    setIsLoading(true);

    try {
      const result = await authService.login(username, password);
      if (result.success) {
        if (onLoginSuccess) onLoginSuccess(result.user);
      } else {
        setError(result.message || 'Geçersiz kullanıcı adı veya şifre.');
      }
    } catch (err) {
      setError('Giriş yapılırken bir hata oluştu.');
    } finally {
      setIsLoading(false);
    }
  };

  const handlePrefill = () => {
    setUsername('admin');
    setPassword('admin123');
    setError('');
  };

  return (
    <div style={{ maxWidth: '480px', margin: '2rem auto' }}>
      <div className="card" style={{ border: '1px solid var(--primary-light)', boxShadow: 'var(--shadow-xl)' }}>
        <div className="card-header" style={{ flexDirection: 'column', alignItems: 'center', textAlign: 'center', padding: '2rem 1.5rem 1.5rem' }}>
          <div style={{ 
            width: '56px', 
            height: '56px', 
            borderRadius: 'var(--radius-xl)', 
            background: 'var(--primary-gradient)', 
            display: 'flex', 
            alignItems: 'center', 
            justifyContent: 'center', 
            color: 'white',
            boxShadow: 'var(--shadow-primary)',
            marginBottom: '1rem'
          }}>
            <ShieldCheck size={28} />
          </div>

          <h2 style={{ fontSize: '1.4rem', fontWeight: 800, color: 'var(--slate-900)' }}>
            Yönetici Güvenlik Girişi
          </h2>
          <p style={{ fontSize: '0.85rem', color: 'var(--slate-500)', marginTop: '0.35rem' }}>
            Klinik kayıt taleplerini onaylamak ve denetim olaylarını yönetmek için lütfen giriş yapın.
          </p>
        </div>

        <div className="card-body" style={{ padding: '1.5rem 2rem 2rem' }}>
          {error && (
            <div style={{ 
              background: 'var(--error-bg)', 
              border: '1px solid var(--error-border)', 
              color: 'var(--error-text)', 
              padding: '0.75rem 1rem', 
              borderRadius: 'var(--radius-md)', 
              fontSize: '0.85rem', 
              display: 'flex', 
              alignItems: 'center', 
              gap: '0.5rem',
              marginBottom: '1.25rem'
            }}>
              <AlertCircle size={16} flexShrink={0} />
              <span>{error}</span>
            </div>
          )}

          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label className="form-label">
                Yönetici Kullanıcı Adı
              </label>
              <div style={{ position: 'relative' }}>
                <input
                  type="text"
                  className="form-input"
                  placeholder="admin"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  style={{ paddingLeft: '2.5rem' }}
                  required
                />
                <User size={16} color="var(--slate-400)" style={{ position: 'absolute', left: '0.85rem', top: '50%', transform: 'translateY(-50%)' }} />
              </div>
            </div>

            <div className="form-group" style={{ marginBottom: '1.5rem' }}>
              <label className="form-label">
                Yönetici Şifresi
              </label>
              <div style={{ position: 'relative' }}>
                <input
                  type="password"
                  className="form-input"
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  style={{ paddingLeft: '2.5rem' }}
                  required
                />
                <KeyRound size={16} color="var(--slate-400)" style={{ position: 'absolute', left: '0.85rem', top: '50%', transform: 'translateY(-50%)' }} />
              </div>
            </div>

            <button
              type="submit"
              disabled={isLoading}
              className="btn btn-primary btn-lg"
              style={{ width: '100%', marginBottom: '1.25rem' }}
            >
              {isLoading ? (
                <span>Giriş Yapılıyor...</span>
              ) : (
                <>
                  <span>Panele Giriş Yap</span>
                  <ArrowRight size={18} />
                </>
              )}
            </button>
          </form>

          {/* Quick Demo Helper */}
          <div style={{ 
            background: 'var(--slate-50)', 
            border: '1px dashed var(--slate-300)', 
            borderRadius: 'var(--radius-md)', 
            padding: '0.85rem 1rem', 
            textAlign: 'center' 
          }}>
            <span style={{ fontSize: '0.8rem', color: 'var(--slate-500)', display: 'block', marginBottom: '0.5rem' }}>
              Tanımlı Yönetici Bilgileri: <strong>admin</strong> / <strong>admin123</strong>
            </span>
            <button
              type="button"
              className="btn btn-secondary btn-sm"
              onClick={handlePrefill}
              style={{ fontSize: '0.785rem' }}
            >
              <Sparkles size={12} color="var(--primary)" />
              <span>Giriş Bilgilerini Otomatik Doldur</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
