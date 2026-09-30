{
  # nixpkgs' URL is declared here rather than left to flake-file, whose
  # dendritic module sets it with lib.mkDefault.
  #
  # When that default moved from .tar.xz to .tar.zst, the generated flake.nix
  # followed — and nix will not re-resolve a tarball input whose URL has
  # changed, so flake.nix and flake.lock disagreed with no way to reconcile
  # them. Discarding the lock made it worse: with nothing to go on, nix
  # resolved the bare name from the flake registry rather than from this URL
  # and pinned a revision four months older.
  #
  # Owning the URL means an update to flake-file can no longer move the most
  # important input in the tree. The same trick works for flake-file's own URL
  # and for import-tree, both also mkDefault, but those are plain github refs
  # that nix re-resolves without complaint.
  flake-file.inputs.nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
}
