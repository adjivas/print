specialisation.vfio-passthrough.configuration = {
  boot.kernelModules = [
    "vfio" "vfio-pci" "vfio_iommu_type1"
  ];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=1002:744c,1002:ab30 # GPU RX7900 GRE, Navi 31
    options kvm ignore_msrs=1 report_ignored_msrs=0
    options kvmfr static_size_mb=64 # Looking-glass
  '';
  boot.kernelParams = [
    "i915.enable_psr=0"
    "intel_iommu=on" "iommu=pt"
  ];
};
