<script setup>
import {ref} from "vue";
import axios from "axios";

const props = defineProps({
  item: {
    type: Object,
    default: () => ({})
  }
})

const url = import.meta.env.VITE_API_URL

const petImage = ref()

const isApiError = ref(false)

const isDeleteButtonDisabled = ref(false)

const isPetImageLoading = ref(false)

const onCLickUploadImage = (petId) => {

  if (!petImage.value || petImage.value.size > 5000000) return

  uploadImage(petId)
}

const uploadImage = (petId) => {

  isPetImageLoading.value = true

  isApiError.value = false

  const formData = new FormData()
  formData.append('image', petImage.value)

  axios.post(url + `/api/pet/${petId}/upload-image`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json'
    }
  }).then(result => {

    petImage.value = null

    isPetImageLoading.value = false

    // const indexToUpdateImages = items.value.findIndex(item => item.id === petId);
    //
    // items.value[indexToUpdateImages].photo_urls = result.data.photo_urls
    document.dispatchEvent(new CustomEvent('fetchData'))

  }).catch(() => {

    console.error('Delete error', error)

    isApiError.value = true

    isPetImageLoading.value = false
  })
}

// delete item on back and remove from list
const deleteItem = (petId) => {

  isApiError.value = false

  isDeleteButtonDisabled.value = true

  const url = import.meta.env.VITE_API_URL

  axios.delete(url + `/api/pet/${petId}`, {
    headers: {
      'Accept': 'application/json'
    }

  }).then(() => {

    // refresh items' list
    document.dispatchEvent(new CustomEvent('fetchData'))

  }).catch(error => {

    console.error('Delete error', error)

    isDeleteButtonDisabled.value = false

    isApiError.value = true
  })
}
</script>

<template>
  <v-alert
    v-if="isApiError"
    color="error"
    class="ma-3"
    closable
  >
    Something went wrong, please try again later
  </v-alert>
  <div class="d-flex flex-row justify-center justify-space-between mb-2 text-h6">
    <div>Pet ID: {{ item.id }}</div>
    <div>Name: {{ item.name }}</div>
    <div>Category: {{ item.category.name }}</div>
    <div>Status: {{ item.status }}</div>
    <div>
      Tags:
      <div v-for="(tag, tagIndex) in item.tags">
        {{ tag.name }}
      </div>
    </div>
  </div>
  <div class="d-flex flex-row flex-wrap justify-center">
    <div
      v-for="(imageUrl, imageIndex) in item.photo_urls"
      class="mx-1 my-1"
    >
      <v-img
        width="210"
        cover
        :src="url + '/storage/' + imageUrl"
      ></v-img>
    </div>
  </div>
  <div class="d-flex flex-row mt-3">
    <v-file-input
      v-model="petImage"
      accept="image/jpeg, image/jpg, image/png, image/webp, image/tiff, image/bmp"
      label="Add image"
      variant="outlined"
      prepend-icon="mdi-camera"
      rounded
      chips
      show-size
      class="mb-2"
      :loading="isPetImageLoading"
      @update:modelValue="onCLickUploadImage(item.id)"
    ></v-file-input>
    <v-btn
      color="red"
      rounded
      class="ml-2"
      :disabled="isDeleteButtonDisabled"
      @click="deleteItem(item.id)"
    >
      Delete Pet
    </v-btn>
  </div>
</template>

<style scoped>
.v-alert {
  border-radius: 24px;
}
</style>
