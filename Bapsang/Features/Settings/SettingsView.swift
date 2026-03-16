//
//  SettingsView.swift
//  Bapsang
//
//  Created by Jun Lee on 3/16/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AuthService.self) private var authService
    @State private var showLogoutConfirm = false
    @State private var showDeleteSheet = false
    @State private var deleteConfirmText = ""
    
    private let deleteKeyword = "Delete Account"
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background matching LoginView
                background
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Account Section
                        sectionCard {
                            VStack(spacing: 0) {
                                sectionHeader("Account")
                                
                                infoRow(
                                    icon: "envelope.fill",
                                    label: "Email",
                                    value: authService.currentUserEmail ?? "-"
                                )
                            }
                        }
                        
                        // App Info Section
                        sectionCard {
                            VStack(spacing: 0) {
                                sectionHeader("App Info")
                                
                                infoRow(
                                    icon: "info.circle.fill",
                                    label: "Version",
                                    value: appVersion
                                )
                            }
                        }
                        
                        // Actions Section
                        sectionCard {
                            VStack(spacing: 0) {
                                actionButton(
                                    icon: "rectangle.portrait.and.arrow.right",
                                    label: "Log Out",
                                    color: .orange
                                ) {
                                    showLogoutConfirm = true
                                }
                                
                                Divider()
                                    .padding(.horizontal, 16)
                                
                                actionButton(
                                    icon: "trash.fill",
                                    label: "Delete Account",
                                    color: .red
                                ) {
                                    deleteConfirmText = ""
                                    showDeleteSheet = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Settings")
            .alert(
                "Are you sure you want to log out?",
                isPresented: $showLogoutConfirm
            ) {
                Button("Log Out", role: .destructive) {
                    Task { await authService.signOut() }
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showDeleteSheet) {
                DeleteAccountSheet(
                    confirmText: $deleteConfirmText,
                    keyword: deleteKeyword
                ) {
                    showDeleteSheet = false
                    Task { await authService.deleteAccount() }
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Background
    
    private var background: some View {
        ZStack {
            Color(.systemBackground)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.orange.opacity(0.15), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: -80, y: -300)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.red.opacity(0.08), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: 120, y: -180)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.yellow.opacity(0.06), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .offset(x: -60, y: 300)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Components
    
    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray4).opacity(0.3), lineWidth: 0.5)
            )
    }
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 8)
    }
    
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(.orange)
                .frame(width: 28)
            
            Text(label)
                .font(.system(size: 15))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
    
    private func actionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(color)
                    .frame(width: 28)
                
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(color)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.quaternary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - Delete Account Sheet

private struct DeleteAccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var confirmText: String
    @FocusState private var isFocused: Bool
    
    let keyword: String
    let onDelete: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.red)
                
                Text("All data will be permanently deleted\nand cannot be recovered.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("To confirm, type **\(keyword)**.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    TextField(keyword, text: $confirmText)
                        .textFieldStyle(.roundedBorder)
                        .focused($isFocused)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                .padding(.horizontal)
                
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Text("Delete Account")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(confirmText != keyword)
                
                Spacer()
            }
            .padding(.top, 24)
            .padding(.horizontal)
            .navigationTitle("Delete Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { isFocused = true }
        }
    }
}
