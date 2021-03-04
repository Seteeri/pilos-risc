void mmu_mair(void);
void mmu_tcr(long long int TG1,
             long long int T1SZ,
             long long int TG0,
             long long int T0SZ);
void mmu_ttrbr0(unsigned long r);
void mmu_sctrlr(void);

void mmu_map_stage1(void);
void mmu_map_stage2(void);
void mmu_map_stage3(void);
