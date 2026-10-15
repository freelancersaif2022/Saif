package com.beam.share.data

import com.beam.share.model.ShareItem
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

/** The files currently chosen to send. Shared by the picker, nearby screen and share-intent handling. */
class SelectionStore {
    private val _items = MutableStateFlow<List<ShareItem>>(emptyList())
    val items: StateFlow<List<ShareItem>> = _items.asStateFlow()

    fun toggle(item: ShareItem) = _items.update { list ->
        if (list.any { it.key == item.key }) list.filterNot { it.key == item.key } else list + item
    }

    fun add(items: List<ShareItem>) = _items.update { list ->
        val keys = list.map { it.key }.toHashSet()
        list + items.filter { keys.add(it.key) }
    }

    fun remove(key: String) = _items.update { list -> list.filterNot { it.key == key } }

    fun set(items: List<ShareItem>) {
        _items.value = items.distinctBy { it.key }
    }

    fun clear() {
        _items.value = emptyList()
    }
}
