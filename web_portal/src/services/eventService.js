// ============================================================================
// Registration Events & Audit Log Service
// Tracks all user & clinic onboarding lifecycle events
// ============================================================================

import { db } from '../firebase';
import { 
  collection, 
  addDoc, 
  getDocs, 
  query, 
  orderBy, 
  limit, 
  onSnapshot 
} from 'firebase/firestore';

const STORAGE_KEY_EVENTS = 'clinicflow_registration_events';

// Default initial realistic registration events
const INITIAL_EVENTS = [
  {
    id: 'evt-101',
    type: 'REGISTRATION_APPROVED',
    category: 'approval',
    title: 'Klinik Kayıt Başvurusu Onaylandı',
    description: 'DentCare & Sağlık Kliniği başvurusu onaylandı ve yönetici hesabı aktif edildi.',
    actor: 'Sistem Yöneticisi (Super Admin)',
    targetUser: 'Dr. Zeynep Kaya (dr.zeynep@clinicflow.com)',
    targetClinic: 'DentCare & Sağlık Kliniği',
    clinicId: 'c101-clinic-001',
    severity: 'success',
    timestamp: new Date(Date.now() - 36 * 3600 * 1000).toISOString(),
    ipAddress: '176.240.12.84',
    clientApp: 'ClinicFlow Web Onboarding',
    metadata: {
      role: 'admin',
      specialty: 'Ortodonti Uzmanı',
      approvedBy: 'Admin Board',
      plan: 'Kurumsal Sağlık'
    }
  },
  {
    id: 'evt-102',
    type: 'ROLE_ASSIGNED',
    category: 'role',
    title: 'Yetki Rolü Atandı',
    description: 'Dr. Zeynep Kaya için "Klinik Yöneticisi (admin)" rolü tanımlandı.',
    actor: 'Sistem Yöneticisi',
    targetUser: 'Dr. Zeynep Kaya',
    targetClinic: 'DentCare & Sağlık Kliniği',
    clinicId: 'c101-clinic-001',
    severity: 'info',
    timestamp: new Date(Date.now() - 35 * 3600 * 1000).toISOString(),
    ipAddress: '176.240.12.84',
    clientApp: 'ClinicFlow Web Admin',
    metadata: { role: 'admin', previousRole: 'unverified' }
  },
  {
    id: 'evt-103',
    type: 'USER_INVITED',
    category: 'invite',
    title: 'Hekim Davet Edildi',
    description: 'Dr. Emre Demir (İmplantolog) klinik ekibine katılmak üzere davet edildi.',
    actor: 'Dr. Zeynep Kaya (Yönetici)',
    targetUser: 'Dr. Emre Demir (dr.emre@dentcare.com)',
    targetClinic: 'DentCare & Sağlık Kliniği',
    clinicId: 'c101-clinic-001',
    severity: 'info',
    timestamp: new Date(Date.now() - 24 * 3600 * 1000).toISOString(),
    ipAddress: '88.255.210.14',
    clientApp: 'ClinicFlow iOS v1.0.2',
    metadata: { invitedRole: 'staff', specialty: 'İmplantoloji' }
  },
  {
    id: 'evt-104',
    type: 'ACCOUNT_ACTIVATED',
    category: 'auth',
    title: 'Hekim Hesabı Aktifleşti',
    description: 'Dt. Seda Yıldız davet bağlantısını onaylayarak parolasını belirledi ve hesabı aktifleşti.',
    actor: 'Dt. Seda Yıldız',
    targetUser: 'Dt. Seda Yıldız (seda.yildiz@dentcare.com)',
    targetClinic: 'DentCare & Sağlık Kliniği',
    clinicId: 'c101-clinic-001',
    severity: 'success',
    timestamp: new Date(Date.now() - 14 * 3600 * 1000).toISOString(),
    ipAddress: '212.156.40.11',
    clientApp: 'ClinicFlow Web Portal',
    metadata: { role: 'staff', verifiedPhone: '+90 555 300 40 50' }
  },
  {
    id: 'evt-105',
    type: 'REGISTRATION_SUBMITTED',
    category: 'submission',
    title: 'Yeni Klinik Başvurusu Alındı',
    description: 'Kadıköy Fizyoterapi & Rehabilitasyon Merkezi yeni klinik açılış başvurusu gerçekleştirdi.',
    actor: 'Fzt. Alperen Çelik',
    targetUser: 'Fzt. Alperen Çelik (alperen@kadikoyfizyo.com)',
    targetClinic: 'Kadıköy Fizyoterapi & Rehabilitasyon Merkezi',
    clinicId: 'req-2026-902',
    severity: 'warning',
    timestamp: new Date(Date.now() - 3 * 3600 * 1000).toISOString(),
    ipAddress: '195.175.254.12',
    clientApp: 'ClinicFlow Web Public Portal',
    metadata: {
      status: 'pending_review',
      city: 'İstanbul / Kadıköy',
      specialty: 'Fizyoterapi & Rehabilitasyon',
      taxNumber: '4829104812',
      staffCount: '6'
    }
  },
  {
    id: 'evt-106',
    type: 'REGISTRATION_SUBMITTED',
    category: 'submission',
    title: 'Yeni Klinik Başvurusu Alındı',
    description: 'Aura Psikoloji & Terapi Enstitüsü başvuru formunu doldurdu. İnceleme bekleniyor.',
    actor: 'Psk. Gamze Şen',
    targetUser: 'Psk. Gamze Şen (gamze@aurapsikoloji.com)',
    targetClinic: 'Aura Psikoloji & Terapi Enstitüsü',
    clinicId: 'req-2026-903',
    severity: 'warning',
    timestamp: new Date(Date.now() - 45 * 60 * 1000).toISOString(),
    ipAddress: '31.223.4.19',
    clientApp: 'ClinicFlow Web Public Portal',
    metadata: {
      status: 'pending_review',
      city: 'İzmir / Alsancak',
      specialty: 'Psikoloji & Danışmanlık',
      taxNumber: '1192847291',
      staffCount: '4'
    }
  }
];

class EventService {
  constructor() {
    this.listeners = new Set();
    this.events = this.loadLocalEvents();
  }

  loadLocalEvents() {
    try {
      const stored = localStorage.getItem(STORAGE_KEY_EVENTS);
      if (stored) {
        return JSON.parse(stored);
      }
    } catch (e) {
      console.warn('LocalStorage error reading events:', e);
    }
    this.saveLocalEvents(INITIAL_EVENTS);
    return [...INITIAL_EVENTS];
  }

  saveLocalEvents(events) {
    try {
      localStorage.setItem(STORAGE_KEY_EVENTS, JSON.stringify(events));
    } catch (e) {
      console.warn('LocalStorage error saving events:', e);
    }
  }

  subscribe(callback) {
    this.listeners.add(callback);
    callback(this.events);
    return () => this.listeners.delete(callback);
  }

  notify() {
    this.listeners.forEach(cb => cb([...this.events]));
  }

  async getAllEvents() {
    return [...this.events];
  }

  async logEvent({
    type,
    category = 'general',
    title,
    description,
    actor = 'Sistem Yöneticisi',
    targetUser = '',
    targetClinic = '',
    clinicId = '',
    severity = 'info',
    metadata = {}
  }) {
    const newEvent = {
      id: `evt-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
      type,
      category,
      title,
      description,
      actor,
      targetUser,
      targetClinic,
      clinicId,
      severity,
      timestamp: new Date().toISOString(),
      ipAddress: '127.0.0.1 (Local Client)',
      clientApp: 'ClinicFlow Web Portal',
      metadata
    };

    // Prepend to local memory & storage
    this.events = [newEvent, ...this.events];
    this.saveLocalEvents(this.events);
    this.notify();

    // Try sending to Firestore if online
    if (db) {
      try {
        await addDoc(collection(db, 'registration_events'), newEvent);
      } catch (err) {
        // Non-blocking fallback to local state
      }
    }

    return newEvent;
  }

  resetToDefault() {
    this.events = [...INITIAL_EVENTS];
    this.saveLocalEvents(this.events);
    this.notify();
    return this.events;
  }

  exportEventsToCsv() {
    const headers = ['Olay ID', 'Zaman', 'Olay Tipi', 'Başlık', 'Açıklama', 'İşlemi Yapan', 'Hedef Kullanıcı', 'Hedef Klinik', 'Önem'];
    const rows = this.events.map(e => [
      e.id,
      new Date(e.timestamp).toLocaleString('tr-TR'),
      e.type,
      `"${(e.title || '').replace(/"/g, '""')}"`,
      `"${(e.description || '').replace(/"/g, '""')}"`,
      `"${(e.actor || '').replace(/"/g, '""')}"`,
      `"${(e.targetUser || '').replace(/"/g, '""')}"`,
      `"${(e.targetClinic || '').replace(/"/g, '""')}"`,
      e.severity
    ]);

    const csvContent = 'data:text/csv;charset=utf-8,\uFEFF' + [headers.join(','), ...rows.map(r => r.join(','))].join('\n');
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    link.setAttribute('download', `clinicflow_kayit_olaylari_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }
}

export const eventService = new EventService();
