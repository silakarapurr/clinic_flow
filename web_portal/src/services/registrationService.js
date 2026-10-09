// ============================================================================
// Registration Application & Users Management Service
// Handles applicant lifecycle, approval workflow, and user directory
// ============================================================================

import { db } from '../firebase';
import { 
  collection, 
  addDoc, 
  updateDoc, 
  doc, 
  getDocs, 
  setDoc 
} from 'firebase/firestore';
import { eventService } from './eventService';

const STORAGE_KEY_APPLICATIONS = 'clinicflow_registration_applications';
const STORAGE_KEY_USERS = 'clinicflow_registered_users';

// Seed Initial Applications
const INITIAL_APPLICATIONS = [
  {
    id: 'CF-REQ-2026-901',
    clinicName: 'DentCare & Sağlık Kliniği',
    clinicType: 'Diş Hekimliği Kliniği',
    doctorName: 'Dr. Zeynep Kaya',
    email: 'dr.zeynep@clinicflow.com',
    phone: '0532 100 20 30',
    taxOrLicenseNumber: 'DIP-TR-349018',
    city: 'İstanbul',
    district: 'Kadıköy',
    address: 'Bağdat Caddesi No: 142/4',
    staffCount: '8',
    specialty: 'Ortodonti Uzmanı',
    status: 'approved', // 'pending' | 'approved' | 'rejected'
    appliedAt: new Date(Date.now() - 36 * 3600 * 1000).toISOString(),
    reviewedAt: new Date(Date.now() - 35 * 3600 * 1000).toISOString(),
    reviewedBy: 'Admin Board',
    rejectionReason: null,
    clinicId: 'c101-clinic-001'
  },
  {
    id: 'CF-REQ-2026-902',
    clinicName: 'Kadıköy Fizyoterapi & Rehabilitasyon Merkezi',
    clinicType: 'Fizyoterapi & Rehabilitasyon',
    doctorName: 'Fzt. Alperen Çelik',
    email: 'alperen@kadikoyfizyo.com',
    phone: '0533 456 78 90',
    taxOrLicenseNumber: 'DIP-TR-884912',
    city: 'İstanbul',
    district: 'Kadıköy',
    address: 'Moda Cad. No: 45 Kat: 2',
    staffCount: '6',
    specialty: 'Sporcu Rehabilitasyonu & Manuel Terapi',
    status: 'pending',
    appliedAt: new Date(Date.now() - 3 * 3600 * 1000).toISOString(),
    reviewedAt: null,
    reviewedBy: null,
    rejectionReason: null,
    clinicId: null
  },
  {
    id: 'CF-REQ-2026-903',
    clinicName: 'Aura Psikoloji & Terapi Enstitüsü',
    clinicType: 'Psikoloji & Terapi',
    doctorName: 'Psk. Gamze Şen',
    email: 'gamze@aurapsikoloji.com',
    phone: '0544 567 89 01',
    taxOrLicenseNumber: 'DIP-TR-672901',
    city: 'İzmir',
    district: 'Alsancak',
    address: 'Kıbrıs Şehitleri Cad. No: 120/5',
    staffCount: '4',
    specialty: 'Klinik Psikoloji & Aile Danışmanlığı',
    status: 'pending',
    appliedAt: new Date(Date.now() - 45 * 60 * 1000).toISOString(),
    reviewedAt: null,
    reviewedBy: null,
    rejectionReason: null,
    clinicId: null
  }
];

// Seed Initial Registered Users (matching ClinicFlow mobile app)
const INITIAL_USERS = [
  {
    id: 'u101-user-001',
    fullName: 'Dr. Zeynep Kaya',
    email: 'dr.zeynep@clinicflow.com',
    role: 'admin',
    roleLabel: 'Klinik Yöneticisi',
    specialty: 'Ortodonti Uzmanı',
    clinicId: 'c101-clinic-001',
    clinicName: 'DentCare & Sağlık Kliniği',
    phone: '0532 100 20 30',
    isActive: true,
    createdAt: new Date(Date.now() - 35 * 3600 * 1000).toISOString()
  },
  {
    id: 'u102-user-002',
    fullName: 'Dr. Emre Demir',
    email: 'dr.emre@dentcare.com',
    role: 'staff',
    roleLabel: 'Hekim / Personel',
    specialty: 'Diş Hekimi & İmplantolog',
    clinicId: 'c101-clinic-001',
    clinicName: 'DentCare & Sağlık Kliniği',
    phone: '0542 200 30 40',
    isActive: true,
    createdAt: new Date(Date.now() - 24 * 3600 * 1000).toISOString()
  },
  {
    id: 'u103-user-003',
    fullName: 'Dt. Seda Yıldız',
    email: 'seda.yildiz@dentcare.com',
    role: 'staff',
    roleLabel: 'Hekim / Personel',
    specialty: 'Pedodonti (Çocuk Diş Hekimi)',
    clinicId: 'c101-clinic-001',
    clinicName: 'DentCare & Sağlık Kliniği',
    phone: '0555 300 40 50',
    isActive: true,
    createdAt: new Date(Date.now() - 14 * 3600 * 1000).toISOString()
  }
];

class RegistrationService {
  constructor() {
    this.appListeners = new Set();
    this.userListeners = new Set();
    this.applications = this.loadLocalApplications();
    this.users = this.loadLocalUsers();
    this.syncDefaultApprovedUsersToFirestore();
  }

  async syncDefaultApprovedUsersToFirestore() {
    if (!db) return;
    try {
      const seedUsers = [
        {
          id: 'u101-user-001',
          email: 'dr.zeynep@clinicflow.com',
          password: '123456',
          full_name: 'Dr. Zeynep Kaya',
          clinic_id: 'c101-clinic-001',
          clinic_name: 'DentCare & Sağlık Kliniği',
          role: 'admin',
          status: 'approved',
          is_active: true
        },
        {
          id: 'admin-super-001',
          email: 'admin@clinicflow.com',
          password: 'admin123',
          full_name: 'Sistem Yöneticisi (Super Admin)',
          clinic_id: 'c101-clinic-001',
          clinic_name: 'ClinicFlow Merkez Yönetim',
          role: 'admin',
          status: 'approved',
          is_active: true
        }
      ];

      for (const u of seedUsers) {
        await setDoc(doc(db, 'approved_users', u.email), u, { merge: true });
      }
    } catch (_) {}
  }

  loadLocalApplications() {
    try {
      const stored = localStorage.getItem(STORAGE_KEY_APPLICATIONS);
      if (stored) return JSON.parse(stored);
    } catch (e) {
      console.warn('LocalStorage applications load error:', e);
    }
    this.saveLocalApplications(INITIAL_APPLICATIONS);
    return [...INITIAL_APPLICATIONS];
  }

  saveLocalApplications(apps) {
    try {
      localStorage.setItem(STORAGE_KEY_APPLICATIONS, JSON.stringify(apps));
    } catch (e) {
      console.warn('LocalStorage applications save error:', e);
    }
  }

  loadLocalUsers() {
    try {
      const stored = localStorage.getItem(STORAGE_KEY_USERS);
      if (stored) return JSON.parse(stored);
    } catch (e) {
      console.warn('LocalStorage users load error:', e);
    }
    this.saveLocalUsers(INITIAL_USERS);
    return [...INITIAL_USERS];
  }

  saveLocalUsers(users) {
    try {
      localStorage.setItem(STORAGE_KEY_USERS, JSON.stringify(users));
    } catch (e) {
      console.warn('LocalStorage users save error:', e);
    }
  }

  subscribeApplications(callback) {
    this.appListeners.add(callback);
    callback(this.applications);
    return () => this.appListeners.delete(callback);
  }

  subscribeUsers(callback) {
    this.userListeners.add(callback);
    callback(this.users);
    return () => this.userListeners.delete(callback);
  }

  notifyApplications() {
    this.appListeners.forEach(cb => cb([...this.applications]));
  }

  notifyUsers() {
    this.userListeners.forEach(cb => cb([...this.users]));
  }

  // 1. Submit Public Clinic Registration
  async submitApplication(formData) {
    const applicationId = `CF-REQ-${new Date().getFullYear()}-${Math.floor(1000 + Math.random() * 9000)}`;
    const newApp = {
      id: applicationId,
      clinicName: formData.clinicName.trim(),
      clinicType: formData.clinicType || 'Diş Hekimliği Kliniği',
      doctorName: formData.doctorName.trim(),
      email: formData.email.trim().toLowerCase(),
      phone: formData.phone.trim(),
      taxOrLicenseNumber: formData.taxOrLicenseNumber?.trim() || '',
      city: formData.city || 'İstanbul',
      district: formData.district || '',
      address: formData.address || '',
      staffCount: formData.staffCount || '3-5 Kişi',
      specialty: formData.specialty || '',
      password: formData.password || 'password123',
      status: 'pending',
      appliedAt: new Date().toISOString(),
      reviewedAt: null,
      reviewedBy: null,
      rejectionReason: null,
      clinicId: null
    };

    this.applications = [newApp, ...this.applications];
    this.saveLocalApplications(this.applications);
    this.notifyApplications();

    // Log registration submitted event
    await eventService.logEvent({
      type: 'REGISTRATION_SUBMITTED',
      category: 'submission',
      title: 'Yeni Klinik Başvurusu Alındı',
      description: `${newApp.clinicName} için ${newApp.doctorName} tarafından yeni kayıt başvurusu yapıldı.`,
      actor: newApp.doctorName,
      targetUser: `${newApp.doctorName} (${newApp.email})`,
      targetClinic: newApp.clinicName,
      clinicId: applicationId,
      severity: 'warning',
      metadata: {
        applicationId,
        specialty: newApp.specialty,
        city: `${newApp.city} / ${newApp.district}`,
        staffCount: newApp.staffCount
      }
    });

    // Sync to Firestore if available
    if (db) {
      try {
        await addDoc(collection(db, 'registration_applications'), newApp);
      } catch (err) {
        // Fallback silently
      }
    }

    return newApp;
  }

  // 2. Submit Staff/Doctor Join Request
  async submitStaffJoin(formData) {
    const applicationId = `CF-STAFF-${new Date().getFullYear()}-${Math.floor(1000 + Math.random() * 9000)}`;
    const newApp = {
      id: applicationId,
      clinicName: formData.clinicCode || 'Davet Kodlu Klinik',
      clinicType: 'Klinik Ekibi Katılımı',
      doctorName: formData.fullName.trim(),
      email: formData.email.trim().toLowerCase(),
      phone: formData.phone.trim(),
      taxOrLicenseNumber: formData.licenseNumber || '',
      city: 'Belirtilmedi',
      district: '',
      address: '',
      staffCount: '1',
      specialty: formData.specialty || 'Hekim / Uzman',
      status: 'pending',
      appliedAt: new Date().toISOString(),
      reviewedAt: null,
      reviewedBy: null,
      rejectionReason: null,
      clinicId: formData.clinicCode || 'c101-clinic-001'
    };

    this.applications = [newApp, ...this.applications];
    this.saveLocalApplications(this.applications);
    this.notifyApplications();

    await eventService.logEvent({
      type: 'REGISTRATION_SUBMITTED',
      category: 'submission',
      title: 'Hekim / Personel Katılım Talebi',
      description: `${newApp.doctorName} (${newApp.specialty}) kliniğe katılma talebinde bulundu.`,
      actor: newApp.doctorName,
      targetUser: `${newApp.doctorName} (${newApp.email})`,
      targetClinic: newApp.clinicName,
      clinicId: newApp.clinicId,
      severity: 'warning',
      metadata: {
        applicationId,
        type: 'staff_join',
        clinicCode: formData.clinicCode
      }
    });

    return newApp;
  }

  // 3. Approve Application
  async approveApplication(appId, adminActor = 'Dr. Zeynep Kaya (Yönetici)') {
    const appIndex = this.applications.findIndex(a => a.id === appId);
    if (appIndex === -1) return null;

    const targetApp = this.applications[appIndex];
    const generatedClinicId = targetApp.clinicId || `c${Math.floor(100 + Math.random() * 900)}-clinic`;
    const newUserId = `u${Math.floor(100 + Math.random() * 900)}-user`;

    const updatedApp = {
      ...targetApp,
      status: 'approved',
      reviewedAt: new Date().toISOString(),
      reviewedBy: adminActor,
      clinicId: generatedClinicId
    };

    this.applications[appIndex] = updatedApp;
    this.saveLocalApplications(this.applications);
    this.notifyApplications();

    // Create user in User Directory
    const newUser = {
      id: newUserId,
      fullName: targetApp.doctorName,
      email: targetApp.email,
      role: 'admin',
      roleLabel: 'Klinik Yöneticisi',
      specialty: targetApp.specialty || 'Klinik Direktörü',
      clinicId: generatedClinicId,
      clinicName: targetApp.clinicName,
      phone: targetApp.phone,
      isActive: true,
      createdAt: new Date().toISOString()
    };

    this.users = [newUser, ...this.users];
    this.saveLocalUsers(this.users);
    this.notifyUsers();

    // Log Approval Event
    await eventService.logEvent({
      type: 'REGISTRATION_APPROVED',
      category: 'approval',
      title: 'Kayıt Başvurusu Onaylandı',
      description: `${targetApp.clinicName} başvurusu onaylandı. ${targetApp.doctorName} için yönetici hesabı oluşturuldu.`,
      actor: adminActor,
      targetUser: `${targetApp.doctorName} (${targetApp.email})`,
      targetClinic: targetApp.clinicName,
      clinicId: generatedClinicId,
      severity: 'success',
      metadata: {
        applicationId: appId,
        assignedRole: 'admin',
        clinicId: generatedClinicId,
        userId: newUserId
      }
    });

    // Also Log Role Assigned
    await eventService.logEvent({
      type: 'ROLE_ASSIGNED',
      category: 'role',
      title: 'Yönetici Rolü Tanımlandı',
      description: `${targetApp.doctorName} hesabına "Klinik Yöneticisi" rolü verildi.`,
      actor: adminActor,
      targetUser: targetApp.doctorName,
      targetClinic: targetApp.clinicName,
      clinicId: generatedClinicId,
      severity: 'info',
      metadata: { role: 'admin' }
    });

    // Sync to Firestore approved_users and clinics collections
    if (db) {
      try {
        const cleanEmail = targetApp.email.toLowerCase();
        await setDoc(doc(db, 'approved_users', cleanEmail), {
          id: newUserId,
          email: cleanEmail,
          password: targetApp.password || 'password123',
          full_name: targetApp.doctorName,
          clinic_id: generatedClinicId,
          clinic_name: targetApp.clinicName,
          specialty: targetApp.specialty || 'Klinik Direktörü',
          phone: targetApp.phone || '',
          role: 'admin',
          status: 'approved',
          is_active: true,
          approved_at: new Date().toISOString(),
          approved_by: adminActor
        });

        await setDoc(doc(db, 'users', newUserId), {
          id: newUserId,
          email: cleanEmail,
          full_name: targetApp.doctorName,
          clinic_id: generatedClinicId,
          role: 'admin',
          is_active: true
        });

        await setDoc(doc(db, 'clinics', generatedClinicId), {
          id: generatedClinicId,
          name: targetApp.clinicName,
          phone: targetApp.phone || '',
          address: `${targetApp.address || ''}, ${targetApp.district || ''} / ${targetApp.city || ''}`,
          lead_doctor: targetApp.doctorName,
          created_at: new Date().toISOString()
        });
      } catch (err) {
        console.warn('Firestore sync error in approveApplication:', err);
      }
    }

    return updatedApp;
  }

  // 4. Reject Application
  async rejectApplication(appId, reason = 'Başvuru bilgileri doğrulanamadı.', adminActor = 'Dr. Zeynep Kaya (Yönetici)') {
    const appIndex = this.applications.findIndex(a => a.id === appId);
    if (appIndex === -1) return null;

    const targetApp = this.applications[appIndex];
    const updatedApp = {
      ...targetApp,
      status: 'rejected',
      reviewedAt: new Date().toISOString(),
      reviewedBy: adminActor,
      rejectionReason: reason
    };

    this.applications[appIndex] = updatedApp;
    this.saveLocalApplications(this.applications);
    this.notifyApplications();

    await eventService.logEvent({
      type: 'REGISTRATION_REJECTED',
      category: 'rejection',
      title: 'Başvuru Reddedildi',
      description: `${targetApp.clinicName} başvurusu reddedildi. Sebep: ${reason}`,
      actor: adminActor,
      targetUser: `${targetApp.doctorName} (${targetApp.email})`,
      targetClinic: targetApp.clinicName,
      clinicId: targetApp.id,
      severity: 'error',
      metadata: {
        applicationId: appId,
        rejectionReason: reason
      }
    });

    return updatedApp;
  }

  // 5. Toggle User Active Status
  async toggleUserStatus(userId, adminActor = 'Dr. Zeynep Kaya (Yönetici)') {
    const userIndex = this.users.findIndex(u => u.id === userId);
    if (userIndex === -1) return null;

    const user = this.users[userIndex];
    const newStatus = !user.isActive;
    this.users[userIndex] = { ...user, isActive: newStatus };
    this.saveLocalUsers(this.users);
    this.notifyUsers();

    await eventService.logEvent({
      type: 'STATUS_TOGGLED',
      category: 'auth',
      title: newStatus ? 'Hesap Aktifleştirildi' : 'Hesap Askıya Alındı',
      description: `${user.fullName} kullanıcısının hesap durumu ${newStatus ? 'Aktif' : 'Pasif'} olarak güncellendi.`,
      actor: adminActor,
      targetUser: `${user.fullName} (${user.email})`,
      targetClinic: user.clinicName,
      clinicId: user.clinicId,
      severity: newStatus ? 'success' : 'warning',
      metadata: { userId, isActive: newStatus }
    });

    return this.users[userIndex];
  }

  // 6. Change User Role
  async updateUserRole(userId, newRole, adminActor = 'Dr. Zeynep Kaya (Yönetici)') {
    const userIndex = this.users.findIndex(u => u.id === userId);
    if (userIndex === -1) return null;

    const user = this.users[userIndex];
    const roleLabel = newRole === 'admin' ? 'Klinik Yöneticisi' : 'Hekim / Personel';
    this.users[userIndex] = { ...user, role: newRole, roleLabel };
    this.saveLocalUsers(this.users);
    this.notifyUsers();

    await eventService.logEvent({
      type: 'ROLE_ASSIGNED',
      category: 'role',
      title: 'Kullanıcı Rolü Değiştirildi',
      description: `${user.fullName} kullanıcısının rolü "${roleLabel}" olarak güncellendi.`,
      actor: adminActor,
      targetUser: `${user.fullName} (${user.email})`,
      targetClinic: user.clinicName,
      clinicId: user.clinicId,
      severity: 'info',
      metadata: { userId, newRole, previousRole: user.role }
    });

    return this.users[userIndex];
  }

  // 7. Invite New User
  async inviteUser({ fullName, email, role, specialty, clinicId, clinicName }, adminActor = 'Dr. Zeynep Kaya (Yönetici)') {
    const newUserId = `u${Math.floor(100 + Math.random() * 900)}-invited`;
    const roleLabel = role === 'admin' ? 'Klinik Yöneticisi' : 'Hekim / Personel';

    const newUser = {
      id: newUserId,
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      role,
      roleLabel,
      specialty: specialty || 'Hekim / Uzman',
      clinicId: clinicId || 'c101-clinic-001',
      clinicName: clinicName || 'DentCare & Sağlık Kliniği',
      phone: 'Davet Bekleniyor',
      isActive: true,
      createdAt: new Date().toISOString()
    };

    this.users = [newUser, ...this.users];
    this.saveLocalUsers(this.users);
    this.notifyUsers();

    await eventService.logEvent({
      type: 'USER_INVITED',
      category: 'invite',
      title: 'Kullanıcı Davet Edildi',
      description: `${newUser.fullName} (${newUser.email}) kliniğe "${roleLabel}" olarak davet edildi.`,
      actor: adminActor,
      targetUser: `${newUser.fullName} (${newUser.email})`,
      targetClinic: newUser.clinicName,
      clinicId: newUser.clinicId,
      severity: 'info',
      metadata: { userId: newUserId, role, specialty: newUser.specialty }
    });

    return newUser;
  }

  // 8. Trigger Password Reset
  async sendPasswordReset(email, adminActor = 'Dr. Zeynep Kaya (Yönetici)') {
    const user = this.users.find(u => u.email.toLowerCase() === email.toLowerCase());
    await eventService.logEvent({
      type: 'PASSWORD_RESET_SENT',
      category: 'security',
      title: 'Şifre Sıfırlama İsteği Gönderildi',
      description: `${email} adresine güvenli şifre belirleme bağlantısı iletildi.`,
      actor: adminActor,
      targetUser: email,
      targetClinic: user ? user.clinicName : 'ClinicFlow',
      clinicId: user ? user.clinicId : 'system',
      severity: 'info',
      metadata: { email, requestedAt: new Date().toISOString() }
    });
    return true;
  }

  // Search application by ID or email
  findApplication(query) {
    const clean = (query || '').trim().toLowerCase();
    if (!clean) return null;
    return this.applications.find(a => 
      a.id.toLowerCase() === clean || 
      a.email.toLowerCase() === clean
    );
  }

  resetToDefault() {
    this.applications = [...INITIAL_APPLICATIONS];
    this.users = [...INITIAL_USERS];
    this.saveLocalApplications(this.applications);
    this.saveLocalUsers(this.users);
    this.notifyApplications();
    this.notifyUsers();
    eventService.resetToDefault();
  }
}

export const registrationService = new RegistrationService();
