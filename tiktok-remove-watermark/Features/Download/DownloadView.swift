//
//  DownloadView.swift
//  tiktok-remove-watermark
//

import SwiftUI

/// Root screen of the download feature. Lays out the full "Save Video"
/// experience from the design spec, wiring states to the view model.
struct DownloadView: View {

    @State private var viewModel: DownloadViewModel

    init() {
        _viewModel = State(initialValue: DownloadViewModel())
    }

    init(viewModel: DownloadViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
//                HeaderBarView()
//                    .padding(.horizontal, AppTheme.Spacing.xLarge)
//                    .padding(.top, AppTheme.Spacing.large)

                TitleBlockView()
                    .padding(.horizontal, AppTheme.Spacing.xxLarge)
                    .padding(.top, AppTheme.Spacing.xxLarge - AppTheme.Spacing.tight)

                content
            }
        }
    }

    // MARK: - Content stack

    private var content: some View {
        VStack(spacing: AppTheme.Spacing.regular) {
            URLField(
                link: $viewModel.link,
                hasError: viewModel.state.isFailed,
                onPaste: triggerFetch,
                onClear: clearLink,
                onSubmit: triggerFetch
            )

            stateSpecificBody

            Spacer(minLength: AppTheme.Spacing.large)

            SaveCTAButton(
                mode: ctaMode,
                isEnabled: ctaEnabled,
                action: ctaAction
            )

            if showsFooterHint {
                Text(AppTheme.Strings.footerHint)
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppTheme.Spacing.xTight)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.xLarge)
        .padding(.top, AppTheme.Spacing.xxLarge)
        .padding(.bottom, AppTheme.Spacing.xLarge)
    }

    @ViewBuilder
    private var stateSpecificBody: some View {
        if let video = viewModel.state.video {
            VideoPreviewCard(video: video)
        }

        switch viewModel.state {
        case .idle:
            InfoBannerView()
        case .fetchingMetadata:
            FeedbackCard(style: .fetching)
        case .readyToSave:
            EmptyView()
        case .saving:
            FeedbackCard(style: .saving)
        case .saved(let video, .savedToPhotos):
            FeedbackCard(style: .success(detail: successDetail(for: video)))
        case .saved(let video, .savedToFiles(let fileURL)):
            FeedbackCard(
                style: .savedToFiles(
                    fileURL: fileURL,
                    detail: successDetail(for: video)
                )
            )
        case .failed(let message):
            FeedbackCard(style: .error(message: message))
        }
    }

    // MARK: - CTA wiring

    private var ctaMode: SaveCTAButton.Mode {
        switch viewModel.state {
        case .saving: return .saving
        case .saved: return .success
        case .failed: return .error
        default: return .idle
        }
    }

    private var ctaEnabled: Bool {
        switch viewModel.state {
        case .readyToSave: return true
        case .failed: return viewModel.hasLink
        default: return false
        }
    }

    private var showsFooterHint: Bool {
        if case .idle = viewModel.state { return true }
        return false
    }

    private func ctaAction() {
        switch viewModel.state {
        case .readyToSave:
            Task { await viewModel.saveVideo() }
        case .failed:
            viewModel.retry()
            Task { await viewModel.fetchVideo() }
        default:
            break
        }
    }

    // MARK: - Helpers

    private func triggerFetch() {
        Task { await viewModel.fetchVideo() }
    }

    private func clearLink() {
        viewModel.reset()
    }

    private func successDetail(for video: TikTokVideo) -> String? {
        guard let duration = video.duration else { return nil }
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d · 1080p", minutes, seconds)
    }
}

#Preview {
    DownloadView()
}
