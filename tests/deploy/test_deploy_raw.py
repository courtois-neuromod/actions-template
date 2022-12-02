import os
import pytest

def test_autoenable(dataset):
    siblings = dataset.siblings()
    sibling_names = [sib['name'] for sib in siblings]
    assert not any('sensitive' in sn for sn in sibling_names), 'Sensitive sibling is autoenabled'
    assert any('mri' in sn for sn in sibling_names), 'MRI sibling is not autoenabled'


def test_files_in_remote(dataset):
    ds_repo = dataset.repo

    mri_sibling = get_mri_sibling(dataset)
    #sensitive_siblings = [sn for sn in sibling_names if 'sensitive' in sn]
    #assert len(sensitive_siblings) == 0, 'sensitive data remote is not expected to be enabled'

    # check that shared files are listed on the share remote
    shared_files_missing = list(ds_repo.call_annex_items_([
        'find', '--not', '--metadata', 'distribution-restrictions=*',
        '--not', '--in', mri_sibling]))
    assert len(shared_files_missing) == 0, f"Files missing in shared remote: \n{shared_files_missing}"

    # check all files are in the shared remote
    fsck_res = ds_repo.fsck(remote=mri_sibling, fast=True)
    fsck_fails = [fr for fr in fsck_res if not fr['success']]
    assert len(fsck_fails) == 0, f"git-annex fsck on {mri_sibling} failed: {fsck_fails}"

    # check that sensitive files are not in the shared remote
    sensitive_files_shared = list(ds_repo.call_annex_items_([
        'find', '--metadata', 'distribution-restrictions=*',
        '--in', mri_sibling]))
    assert len(sensitive_files_shared) == 0, f"Sensitive files mistakenly shared: \n{sensitive_files_shared}"

def get_mri_sibling(dataset):
    siblings = dataset.siblings()
    sibling_names = [sib['name'] for sib in siblings]
    mri_siblings = [sn for sn in sibling_names if sn.split('.')[-1] == 'mri']
    assert len(mri_siblings) == 1, 'a single non-sensitive mri remote is expected'
    return mri_siblings[0]
